module Reactor
  module Tools
    class WorkflowGenerator
      attr_reader :obj, :users, :editors, :correctors, :groups, :workflow_name

      def initialize(options)
        @editors    = options[:editors]
        @correctors = options[:correctors]
        @users      = @editors + @correctors
        @groups     = personal_groups(@users)
        @class_name = options[:obj_class] || generate_obj_class_name
        @workflow_name = options[:workflow_name] || generate_workflow_name
        @obj_name = options[:obj_name] || generate_obj_name
      end

      def generate!
        create_groups
        create_users
        create_signatures
        create_workflow
        create_obj_class
        create_obj
        set_permissions
        start_workflow
      end

      def destroy!
        destroy_objs
        destroy_obj_class
        destroy_workflow
        destroy_users
        destroy_groups
        destroy_signatures
      end

      def personal_group(user)
        "#{user}_group"
      end

      protected

      def personal_signature(user)
        "#{user}_signature"
      end

      def personal_groups(users)
        users.map { |user| personal_group(user) }
      end

      def create_groups
        @groups.each do |group|
          if Reactor::Cm::Group.exists?(group)
            Reactor::Cm::Group.get(group)
          else
            Reactor::Cm::Group.create(name: group)
          end
        end
      end

      def create_users
        @users.each do |user|
          internal_user = if Reactor::Cm::User::Internal.exists?(user)
                            Reactor::Cm::User::Internal.get(user)
                          else
                            Reactor::Cm::User::Internal.create(user, personal_group(user))
                          end

          internal_user.change_password("thepasswordispassword")
        end
      end

      def create_signatures
        # hash storing users as keys and attribute names as values
        @signatures = {}
        @users.each do |user|
          signature = personal_signature(user)
          if Reactor::Cm::Attribute.exists?(signature)
            # Reactor::Cm::Attribute.get(signature)
            @signatures[user] = signature
          else
            Reactor::Cm::Attribute.create(signature, "signature")
            @signatures[user] = signature
          end
        end
      end

      def create_workflow
        @workflow = if Reactor::Cm::Workflow.exists?(@workflow_name)
                      Reactor::Cm::Workflow.get(@workflow_name)
                    else
                      Reactor::Cm::Workflow.create(@workflow_name)
                    end

        # set up workflow steps
        @workflow.edit_groups = personal_groups(@editors)

        serialized_signatures = []
        @correctors.each do |corrector|
          signature = {
            group: personal_group(corrector),
            attribute: @signatures[corrector]
          }
          serialized_signatures << signature
        end
        @workflow.signatures = serialized_signatures

        @workflow.save!
        @workflow.reload
      end

      def create_obj_class
        @obj_class = if Reactor::Cm::ObjClass.exists?(@class_name)
                       Reactor::Cm::ObjClass.get(@class_name)
                     else
                       Reactor::Cm::ObjClass.create(@class_name, "publication")
        end
      end

      def create_obj
        @obj = Reactor::Cm::Obj.create(@obj_name, "/", @class_name)
        @obj.set(:workflowName, @workflow_name)
        @obj.save!
      end

      def set_permissions
        # get RC object
        @rc_obj = RailsConnector::AbstractObj.find(@obj.obj_id)

        # use nice API to set permissions
        @groups.each do |group|
          @rc_obj.permission.grant(:read, group)
          @rc_obj.permission.grant(:write, group)
        end

        # Allow Dirk to release the object
        @rc_obj.permission.grant(:root, personal_group(@correctors.last))
      end

      def start_workflow
        @obj.release!
        Reactor::Sudo.su(@editors.first) do
          @obj.edit!
        end
      end

      def destroy_objs
        RailsConnector::AbstractObj.where(obj_class: @class_name).each(&:destroy)
      end

      def destroy_obj_class
        @obj_class.delete!
      end

      def destroy_workflow
        @workflow.delete!
      end

      def destroy_users
        @users.each do |user|
          Reactor::Cm::User::Internal.get(user).delete!
        end
      end

      def destroy_groups
        @groups.each do |group|
          Reactor::Cm::Group.get(group).delete!
        end
      end

      def destroy_signatures
        @signatures.values.each do |attribute|
          Reactor::Cm::Attribute.get(attribute).delete!
        end
      end

      def generate_workflow_name
        "GeneratedWorkflow#{generate_token}"
      end

      def generate_obj_name
        "generated_obj#{generate_token}"
      end

      def generate_obj_class_name
        "GeneratedObjClass#{generate_token}"
      end

      def generate_token
        characters = ("0".."9").to_a + ("A".."Z").to_a + ("a".."z").to_a
        Array.new(8) { characters[rand(characters.length)] }.join
      end
    end
  end
end

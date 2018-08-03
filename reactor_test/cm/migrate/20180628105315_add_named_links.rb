class AddNamedLinks < ActiveRecord::Migration[5.1]
  def change
    create_attribute :name => 'related_links', :type => 'linklist'
    create_class :name => 'NamedLink', :type => 'document' do
      set :title, {'NamedLink' => {:lang => :de}, 'NamedLink Page' => {:lang => :en}}
      take :related_links
    end
  end
end

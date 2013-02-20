REACTOR
=======

RailsConnector EnhAnCements for TCL lOveRs. You all love RailsConnector. I know you do. It delivers nice features and great performance. And yet... An yet you always knew that something is missing. You had this feeling when writing TCL code. You had this feeling when fiddling in Fiona GUI. Yes. You know it. You are a Rails coder: `BeatufiulPage.create(:name => 'Better page', :parent => '/best/pages', :title => 'Yes, it is better')`. Write layer is missing in RailsConnector. And it shows.

So, here you have it: REACTOR, writing layer for `RailsConnector`, tightly integrated with `ActiveRecord`. Maybe some of you don't like long and creative descriptions. Maybe some of you are convinced with running code:

    BeatufiulPage.create(:name => 'Better page', :parent => '/best/pages', :title => 'Yes, it is better') do |page|
      page.body = '<a href="/can/handle/links/too">link</a>'
      page.save!
      page.release!
    end

    other_page = OtherPage.last
    other_page.take!

    not_a_page = SomeObject.first
    not_a_page.some_attribute = 'a value' # types: string, html, enum
    not_a_page.multienum_attr = ['somevalue'] # multienum
    not_a_page.some_date_attribute = Time.now # date
    not_a_page.some_date_attribute = '20111011083526' # date
    not_a_page.some_date_attribute = '2011-11-11'

    not_a_page.release! if not_a_page.valid?(:release)

All of the above are examples of what can be done with `Persistence`, `Validations`, `Attributes`. There is more:
* all standard ActiveModel callbacks + `*_release` callbacks
* Validations in three contexts: create, update, release
* If something works with ActiveRecord, there is a high chance it works with REACTOR too!
* Rails 3 API

What about links? Every object on my page is linked with 1000 other objects! I need links! Don't worry, they are there. Not perfectly supported yet, but you can set them:

    some_obj.link_list_attr = 'http://google.com'
    some_obj.link_list_attr = Obj.last
    some_obj.link_list_attr = '/path/to/obj'

And I haven't forgotten that they are lists of links:

    some_obj.link_list_attr = ['http://google.com', Obj.last, '/path/to/obj']

Yes, that is nice, you say, but what if I also wan't to set a link title? No problem, here is how:

    some_obj.link_list_attr = {:url => 'http://google.com', :title => 'title of my link'}
    some_obj.link_list_attr = {:destination_object => Obj.last, :title => 'title of my link'}
    some_obj.link_list_attr = {:destination_object => '/path/to/obj', :title => 'title of my link'}

This also works for multiple links:

    some_obj.link_list_attr = [ {:url => 'http://google.com', :title => 'title of my link'}, {:destination_object => Obj.last, :title => 'other title'}]

You can also manipulate linklist with array methods (for example `#delete_at`) and

    some_obj.link_list_attr << '/path/to/obj'
    some_obj.link_list_attr << {:url => 'http://yahoo.com', :title => 'yahoo link'}

One more thing: you can upload files too!

    binary_obj.upload(File.open('/my/file'), 'txt')
    binary_obj.save!

Or:

    binary_obj.upload(File.read('/my/file'), 'txt')
    binary_obj.save!

**WARNING** If your are planning to upload anything larger than 10kB it is strongly advised to use `Reactor::StreamingUpload` module. This module
allows to stream files of any size (provided you supply them through `File.open` and not read them yourself into memory). It is also much,
much more efficient than the traditional method.

Permissions are checked also! And your user is automatically set according to `JSESSIONID` cookie.

KNOWN BUGS/ISSUES
=================

Awesome! What is missing/WHAT I NEED TO BE AWARE OF:

- When setting a `linklist` all links are overwritten. Don't do it like 10 million times if you don't want to risk reaching billion ids.
- Therefore link operations are slow. 
- Link position cannot be directly manipulated (it is implicit through array order)
- Validations are implemented completely in Rails, there is no call to CM, so all you TCL validation callbacks aren't executed
- You can change the `obj_class` of an obj, but after save you should get yourself a new instance. (it's a bug of `rails_connector_meta`)
- You have to save an object before you can upload data (i.e. upload works only on existing objects)

HOW TO INSTALL
==============

1. Include in your Gemfile
2. bundle
3. Add initializer for Reactor if you haven't done so already
4. Include modules into your Obj

CONFIGURING CMS ACCESS
======================

**config/initializers/reactor.rb:**

    Reactor::Configuration.xml_access = {
      :host => 'localhost', # Fiona host
      :port => 6001, # CM http port (TCL port + 1)
      :id => '1234', # leave it as is

      :username => 'root', # default user for all requests
      :secret => 'password' # instance secret
    }

USING WITH THE NEWEST RAILS CONNECTOR
=====================================

Recent versions of Rails Connector deprecated the usage of `ObjExtenions` module. Therefore, you have to create an `Obj` model which inherits the `RailsConnector::BasicObj` class. **For best compatibility do not call that model anything other that `Obj`!

**app/models/obj.rb:**

    require 'meta'
    class Obj < RailsConnector::BasicObj
          include RailsConnector::Meta

          include Reactor::Legacy::Base       # core module
          include Reactor::Attributes::Base   # core module
          include Reactor::Persistence::Base  # core module

          include Reactor::Validations::Base  # optional module, 
                                              #  enables Rails validations

          include Reactor::Permission::Base   # optional module,
                                              #  enables permission checking

          include Reactor::Workflow::Base     # optional module,
                                              #  enables workflow API

          include Reactor::StreamingUpload::Base
                                              # optional module,
                                              #  enables streaming interface for
                                              #  uploads (strongly recommended!)
    end

USING WITH OLDER RAILS CONNECTOR
================================

Older version of Rails Connector support extensions to the RailsConnector::Obj class through `ObjExtensions` module. Use following code for the best compatibility.

**lib/obj_extensions.rb:**

    require 'meta'
    module ObjExtensions
      def self.enable
        Obj.class_eval do
          include RailsConnector::Meta

          include Reactor::Legacy::Base       # core module
          include Reactor::Attributes::Base   # core module
          include Reactor::Persistence::Base  # core module

          include Reactor::Validations::Base  # optional module, 
                                              #  enables Rails validations

          include Reactor::Permission::Base   # optional module,
                                              #  enables permission checking

          include Reactor::Workflow::Base     # optional module,
                                              #  enables workflow API

          include Reactor::StreamingUpload::Base
                                              # optional module,
                                              #  enables streaming interface for
                                              #  uploads (strongly recommended!)
        end
      end
    end

DOCUMENTATION
=============
Core and optional modules are pretty well documented. If you are looking for example usages, you will find plenty of them in test app under spec folder.

BUGS, FEATURE REQUESTS?
=======================
Open issue on github or make a pull request! Don't be shy :)

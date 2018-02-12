if ::Rails::VERSION::MAJOR == 5
  class Obj < RailsConnector::BasicObj
    # puts "load Obj"
    # include Reactor::Main
  end
else
  PARENT_CLASS = begin
                   RailsConnector::BasicObj
                 rescue NameError
                   RailsConnector::Obj
                 end

  begin
    # RailsConnector::BasicObj
    class Obj < RailsConnector::BasicObj
    end
  rescue NameError #running older rails connector without RailsConnector::BasicObj
    Obj = RailsConnector::Obj
  end

  # reopen the class and add modules
  class Obj < RailsConnector::BasicObj
    include Reactor::Main
  end
end

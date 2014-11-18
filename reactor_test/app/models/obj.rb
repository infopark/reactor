PARENT_CLASS = begin
                 RailsConnector::BasicObj
               rescue NameError
                 RailsConnector::Obj
               end

begin
  RailsConnector::BasicObj
  class Obj < RailsConnector::BasicObj
  end
rescue NameError #running older rails connector without RailsConnector::BasicObj
  Obj = RailsConnector::Obj
end

# reopen the class and add modules
class Obj
  include Reactor::Main
end

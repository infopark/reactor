class AddNamedLinks < Reactor::Migration
  def self.up
    create_attribute name: 'related_links', type: 'linklist'
    create_class name: 'NamedLink', type: 'document' do
      set :title,
          'NamedLink' => { lang: :de },
          'NamedLink Page' => { lang: :en }

      take :related_links
    end
  end

  def self.down
    delete_class name: 'NamedLink'
    delete_attribute name: 'related_links'
  end
end

module Jekyll
  class CategoryLastModifiedTag < Liquid::Tag
    def initialize(tag_name, args, tokens)
      super
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]
      dates = site.categories[page['category']].map{|x| x.date}
      dates.max.xmlschema
    end
  end
end
Liquid::Template.register_tag('category_last_modified', Jekyll::CategoryLastModifiedTag)

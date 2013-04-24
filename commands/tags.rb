usage       "tags [options]"
summary     "Build tag pages"
description "Generates tag index pages for Cloud Foundry Docs"

flag   :h, :help,  "show help for this command" do |value, cmd|
  puts cmd.help
  exit 0
end


run do |opts, args, cmd|
  output_dir = "content/tags"
  FileUtils.rm_r(output_dir)
  FileUtils.mkdir(output_dir)

  require "nanoc3"
  require "nanoc/cli/logger"

  # Load nanoc site
  site = Nanoc3::Site.new(".")

  pages_with_tags = {}

  # Get all tags used on the site
  site.items.each do |item|
    if item[:tags]
      item[:tags].each do |tag|
        unless pages_with_tags.has_key?(tag)
          pages_with_tags[tag] = []
        end
        pages_with_tags[tag] << item
      end
    end
  end

  main_file = File.new("content/tags/tags.md", "w")
  main_content = "---\ntitle: Tags\n---\n"
  pages_with_tags.each do |tag, items|
    content = "---\ntitle: #{tag}\ndescription: Articles for #{tag}\n---\n\n"
    main_content << "* [#{tag}](/tags/#{tag}) -- #{items.count} articles\n"
    items.each do |item|
      content << "* [#{item[:title]}](#{item.path}) - #{item[:description]}\n"
    end
    file = File.new("content/tags/#{tag}.md", "w")
    file.write(content)
    file.close
  end
  main_file.write(main_content)
  main_file.close

  puts
  puts("Tags indices generated.")
end
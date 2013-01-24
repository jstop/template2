require 'rubygems'
require 'open-uri'
require 'base64'

TMPL_OUT = "../public/javascripts/templates.js"

desc "Compile Templates"
task :templates do
  File.delete(TMPL_OUT) if File.exists?(TMPL_OUT)
  Dir.glob("../views/**/*.handlebars").each do |file|
    puts "Compiling: #{file}"
    tmpl = %x[handlebars #{file}]
    File.open(TMPL_OUT, 'a') {|f| f.write(tmpl)}
  end
end

desc "Production"
task :production do
  optimize
  base64_encode_images("stylesheets/main.css")
  remove_dev_files
end

def optimize
  system("r.js -o js/build.js")
end

def base64_encode_images(file)
  ret = ""
  IO.read(file).split("\n").each do |line|
    captures = line.match(/background.*url\((.*)\)/)
    if captures.nil? or captures[1].include?("..") # Not handling relative paths for now
      ret += line + "\n"
    else
      capture =  captures[1]
      img_data = Base64.encode64(IO.read('build/' + capture)).gsub("\n", '')
      img_type = capture.match(/\.(png|jpeg|jpg|gif)/).captures[0]
      ret += line.gsub(capture, "'data:image/#{img_type};base64,#{img_data}'") + "\n"
    end
  end
  File.open(file, 'w') {|f| f.write(ret)}
end

def remove_dev_files
  files_to_keep = ["main.js", "require.js", "main.css", "index.haml"]
  Dir["**/*"].select {|f| File.file?(f)}.each do |file_path|
    file_name = File.basename(file_path)
    rm file_path if !files_to_keep.include?(file_name)
  end
  delete_empty_dirs
end

def delete_empty_dirs
  Dir["**/*"] \
    .select {|d| File.directory?(d)} \
    .sort {|x, y| y.split('/').size <=> x.split('/').size} \
    .each {|dir| system("find #{dir} -type d -empty | xargs rm -rf")}
end

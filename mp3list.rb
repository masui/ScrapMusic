#
# 新しい写真ファイルをGyazoとS3に追加し、Scrapboxに登録
# されているものとの差分のJSONをaddfiles.jsonに出力
#

# Usage: % ruby mp3list.rb mp3の入ってるディレクトリ

require 'digest/md5'
require 'shellwords'

bucket = 'masui.org'

dir = ARGV[0]
unless dir
  exit
end

# dir = '/Users/masui/Music/Music/Media.localized/Music/Ahmad Jamal/Poinciana'

File.open('list.txt','w'){ |f|
  Dir.open(dir).each { |file|
    if file =~ /\.mp3/
      path = "#{dir}/#{file}"
      # puts path
      md5 = Digest::MD5.new.update(File.read(path)).to_s
      # puts md5
      s3url = "https://s3-ap-northeast-1.amazonaws.com/#{bucket}/#{md5[0]}/#{md5[1]}/#{md5}.mp3"
      title = file.sub(/\.mp3/,'')
      f.puts " [#{s3url} #{title}]"
      s = Shellwords.escape("#{dir}/#{file}")
      STDERR.puts "upload #{s}"
      system "upload #{s}"
    end
  }
}

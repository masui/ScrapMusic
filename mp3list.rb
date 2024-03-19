#!/usr/bin/env ruby
#
# mp3ファイルをS3にアップロードしてScrapbox記述を生成
#
# Usage: % ruby mp3list.rb dir
#

require 'digest/md5'
require 'shellwords'
require 'cgi'

dir = ARGV[0]
if dir.to_s == "" || !File.exist?(dir)
  STDERR.puts "Usage: % ruby mp3list.rb dir"
  exit
end

files = []

Dir.open(dir).each { |file|
  if file =~ /\.mp3/
    path = "#{dir}/#{file}"
    md5 = Digest::MD5.new.update(File.read(path)).to_s
    s3url = "https://s3-ap-northeast-1.amazonaws.com/masui.org/#{md5[0]}/#{md5[1]}/#{md5}.mp3"
    title = file.sub(/\.mp3/,'')
    files.push [title, s3url]
    s = Shellwords.escape("#{dir}/#{file}")
    STDERR.puts "upload #{s}"
    system "upload #{s}"
  end
}
files = files.sort { |a,b|
  a[0] <=> b[0]
}

listfile = "/tmp/mp3list.txt"
File.open(listfile,'w'){ |f|
  all = ' [すべて再生 https://scrapmusic.org/?urls='
  all += files.map { |e| CGI.escape(e[1]) }.join("%2C")
  all += '&titles='
  all += files.map { |e| CGI.escape(e[0]).gsub('+','%20') }.join("%2C")
  all += ']'
  f.puts all
  f.puts
  
  files.each { |e|
    f.puts " [#{e[0]} #{e[1]}]"
  }
}

system "cat #{listfile} | pbcopy"


# ALL
# [https://scrapmusic.org/?urls=https%3A%2F%2Fs3-ap-northeast-1.amazonaws.com%2Fmasui.org%2F5%2Ff%2F5f23cfb921bc8b0d6fb1437ff153925b.mp3%2Chttps%3A%2F%2Fs3-ap-northeast-1.amazonaws.com%2Fmasui.org%2F4%2Fd%2F4d1d65a047047b4bf4f1b18a5d0a8844.mp3%2Chttps%3A%2F%2Fs3-ap-northeast-1.amazonaws.com%2Fmasui.org%2Fe%2F3%2Fe3283a51233e053cb804c14bff9a88bc.mp3%2Chttps%3A%2F%2Fs3-ap-northeast-1.amazonaws.com%2Fmasui.org%2Fd%2Fe%2Fdeafcf67a250d32307d770eac5b3c56d.mp3%2Chttps%3A%2F%2Fs3-ap-northeast-1.amazonaws.com%2Fmasui.org%2Fd%2F7%2Fd7a7e818d49b330d989a10668167f46d.mp3%2Chttps%3A%2F%2Fs3-ap-northeast-1.amazonaws.com%2Fmasui.org%2F7%2Fd%2F7d22736142dfb4e22149f4dee72e28c2.mp3&titles=01%2520You%27re%2520Everything%2C02%2520Light%2520As%2520a%2520Feather%2C03%2520Captain%2520Marvel%2C04%2520500%2520Miles%2520High%2C05%2520Children%27s%2520Song%2C06%2520Spain All]


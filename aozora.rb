# vim:set fileencoding=UTF-8
require 'bundler'
Bundler.require

#姓と名の間に半角スペース
keyword = "江戸川乱歩"
#「江戸川」のときは「あ行」。50音にないときは「他」。
initial = "あ"
top_url = "http://www.aozora.gr.jp/"

dir_path = "./output/"
FileUtils.mkdir_p(dir_path) unless FileTest.exist?(dir_path)

#公開中の全作品の文字数をゲットする
#ID 作品名 文字数　という形式のTSVを出力
$templine = Array.new(0)

agent = Mechanize.new
agent.user_agent_alias = 'Windows IE 9'
top_page = agent.get(top_url)
top_page.links_with(:href => /person/).each do |link|
  #「あ行」の作家のページに行く
  if link.text[initial] then
    person_list = link.click
    person_list.links_with(:href => /person/).each do |link|
      #江戸川乱歩のページに行く
      if link.text[keyword] then
        listofworks = link.click
        i = 0
        listofworks.links_with(:href => /cards/).each do |link|
          #公開中の全作品リストをゲットする。
          t = link.text.encode("UTF-8")
          $templine[i] = t
          i+=1
        end
        File.open(dir_path + keyword + ".tsv", "w:UTF-8") do |f|
          f.puts($templine)
        end
      end
    end
  end
end

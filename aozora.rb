require 'bundler'
Bundler.require

keyword = "江戸川乱歩"
initial = "あ"
top_url = "http://www.aozora.gr.jp/"

dir_path = "./output"
FileUtils.mkdir_p(dir_path) unless FileTest.exist?(dir_path)

#「あ行」の作家のページに行く
#江戸川乱歩のページに行く
#公開中の全作品リストをゲットする。
#公開中の全作品の文字数をゲットする
#ID 作品名 文字数　という形式のTSVを出力

agent = Mechanize.new
agent.user_agent_alias = 'Windows IE 9'
top_page = agent.get(top_url)
top_page.links_with(:href => /person/).each do |link|
  puts link.href
end

# vim:set fileencoding=UTF-8
require 'bundler'
Bundler.require

#西洋の作家の場合、ファミリーネームかファーストネームのみ使う。ミドルネームは中黒。
##例：
##keyword = "クロポトキン"
##例：
##keyword = "オー・ヘンリー"
##芥川龍之介は「芥川竜之介」でなければヒットしない。
keyword = "夢野久作"
#「江戸川」のときは「あ」行。
initial = "や"
top_url = "http://www.aozora.gr.jp/"
dir_path = "./output/"
FileUtils.mkdir_p(dir_path) unless FileTest.exist?(dir_path)

#公開中の全作品の文字数をゲットする
#ID<TAB>作品名<TAB>文字数、という形式のTSVを出力
$templine = Array.new(0)

agent = Mechanize.new
agent.user_agent_alias = 'Windows IE 9'
top_page = agent.get(top_url)
#「作家別」リストを見る
top_page.links_with(:href => /person/).each do |link|
  #「あ行」の作家のページに行く
  if link.text[initial] then
    person_list = link.click
    #江戸川乱歩のページに行く
    person_list.links_with(:href => /person/).each do |link|
      #姓名間の空白をトリム
      author = link.text.gsub(" ", "")
      #江戸川乱歩の作品リストを取得
      if author.include?(keyword) then
        listofworks = link.click
        i = 0
        listofworks.links_with(:href => /cards/).each do |link|
          #公開中の全作品リストをゲットする。
          item = link.text.encode("UTF-8")
          #カードページに行く
          card = link.click
          p card.search('div.copyright')
          #HTMLを見る
          #「著作権存続」のものはスキップ
          unless card.at('div.copyright') then
            begin
              article = card.links_with(:href => /files/)[0].click
              char_num = article.search('body').inner_text.length
              $templine[i] = (i+1).to_s + "\t" + item + "\t" + char_num.to_s
              i+=1
            rescue
              #特殊フォーマットのものはスキップしてタイトル表示
              #宮沢賢治「春と修羅」など
              puts card.search('title').inner_text
            end
          end
        end
        File.open(dir_path + keyword + ".tsv", "w:UTF-8") do |f|
          f.puts($templine)
        end
      end
    end
  end
end

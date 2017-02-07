require 'nokogiri'
require 'json'
# require 'pry'

# # check unicode values for arabic characters (between 1571 and 1618)
# ara_chars = "ابتثجحخدذرزسشصضطظعغفقكلمنهويأإىؤءئًٌٍَُِّْ"
# ara_chars.chars.each { |char| puts char + ": " + char.ord.to_s } 

hw_source = File.open("hanswehr.xml") { |f| Nokogiri::XML(f) }

styles = Hash.new {|h,k| h[k]=[]}

hw_source.xpath("//style:paragraph-properties[@fo:margin-left]").each do |s|
    styles["#{s["fo:margin-left"].delete('in').to_f + s["fo:text-indent"].delete('in').to_f}"] << s.parent["style:name"]
end

p "alif hamza: " "أ".ord

root_word_styles = styles["0.0"]

regex = /(?<= |^)[\u0620-\u0660 ]+(?= |$)/
current_root = nil;
autonum = 1

root_words = hw_source.xpath("//office:text/text:p")
	.map{ |tag| 
            is_root = check_is_root(tag)
            word = { 
            	id: autonum,
                word: regex.match(tag.text).to_s, 
                text: tag.text, 
                is_root: is_root,
                root: current_root
            }
            current_root = autonum if is_root
            autonum += 1 
           	word
        } 

File.write 'results.json', root_words[0...1000].to_json

def check_is_root(tag) {
	root_word_styles.include?(tag.attributes["style-name"].value)
}


# Pry::ColorPrinter.pp(styles.sort_by{|k,v| k}.to_h)

# f_out = File.new("out.txt", "w+")

# f_out.write hw_source.xpath("//text:p[@text:style-name='P15']").first
# f_out.close
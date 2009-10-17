#!/usr/bin/env ruby1.9
# vim:fileencoding=utf-8
require 'curses'
require 'yaml'

class Puresen
  include Curses

  def initialize(yaml_path)
    Curses.init_screen
    load_file yaml_path
  end

  def load_file(yaml_path)
    @yaml_path = yaml_path
    @pages = YAML.load_file yaml_path
  end

  def reload_file
    load_file @yaml_path
  end

  def start
    page_num = 0
    loop do
      page = @pages[page_num] || break
      print_test page['title'], page['body']
      case wait
      when 'b'
        page_num = [0, page_num-1].max
      when 'q'
        break
      when 'r'
        reload_file
        redo
      else
        page_num = [page_num+1, @pages.length-1].min
      end
    end
  end

  def wait
    str = getstr
    clear
    str
  end

  def print_test(title, text)
    pt '=' * (cols-1)
    pt "\n#{title}\n"
    pt '=' * (cols-1)
    pt
    pt text
    refresh
  end

  def pt(str='')
    addstr "#{str}\n"
    refresh
  end
end

begin
  unless yaml_path = ARGV.shift
    puts "usage: #{$0} <yaml_path>"
    exit 1
  end
  
  a = Puresen.new(yaml_path)
  a.start

ensure
  Curses.close_screen
end

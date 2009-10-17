#!/usr/bin/env ruby1.9
# vim:fileencoding=utf-8
require 'curses'
require 'yaml'
require 'logger'

BASE_DIR = File.dirname __FILE__
LOG_DIR  = File.join BASE_DIR, 'log'
Dir.mkdir LOG_DIR rescue
$log = Logger.new(File.join(LOG_DIR, 'puresen.log'))


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
    @page_num = 0
    loop do
      page = @pages[@page_num] || break
      print_page
      key = wait
      $log.debug "key=#{key.inspect}"
      case key
      when 'b'
        @page_num = [0, @page_num-1].max
      when 'q'
        break
      when 'r'
        reload_file
        redo
      when 410
        # Cmd+'-', Cmd+'+' : ignore
      else
        @page_num = [@page_num+1, @pages.length-1].min
      end
    end
  end

  def wait
    str = getch
    clear
    str
  end

  def print_page
    page = @pages[@page_num]
    pt '=' * (cols-1)
    standout
    pt "\n#{page['title']}\n"
    standend
    pt '=' * (cols-1)
    pt
    pt page['body']
    print_page_str
  end

  def pt(str='')
    addstr "#{str}\n"
    refresh
  end

  def print_page_str
    bufx = stdscr.curx
    bufy = stdscr.cury

    page_str = "#{@page_num+1} / #{@pages.length}"
    setpos(2, cols - page_str.length - 2)
    pt(page_str)

    setpos(bufy, bufx)
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

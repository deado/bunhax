class Menu
        def Menu.help
                puts " #{$head} bunhax - cpuset manager #{$head}"
                puts "  a #{$c1}-#{$c2} move multiple PIDs to a cpuset"
                puts "  c #{$c1}-#{$c2} change application colors 'on the fly'"
                puts "  d #{$c1}-#{$c2} delete cpuset"
		puts "  e #{$c1}-#{$c2} edit cpuset's usable cpus and mems"
                puts "  h #{$c1}-#{$c2} display help menu"
                puts "  l #{$c1}-#{$c2} display available cpusets"
                puts "  m #{$c1}-#{$c2} move PID to cpuset"
                puts "  n #{$c1}-#{$c2} create new cpuset"
                puts "  p #{$c1}-#{$c2} display cpuset tasks"
                puts "  q #{$c1}-#{$c2} quit"
                puts "  v #{$c1}-#{$c2} display version information"
                puts "  z #{$c1}-#{$c2} execute 'screen -d' (only works if running in screen)"
        end
        def Menu.version
                #this is the version information... please leave it in tact..
                puts " #{$head} bunhax - cpuset manager #{$head}"
                puts "   Version#{$c1}:#{$c2} 0#{$c1}.#{$c2}2#{$c1}.#{$c2}3#{$c1}-#{$c2}rb"
                puts "   Updated#{$c1}:#{$c2} 15 November 2007 (13:45 CST)"
                puts "   Author#{$c1}:#{$c2} Jeremy #{$c1}\"#{$c2}deado#{$c1}\"#{$c2} Polley"
                puts "   Email#{$c1}:#{$c2} jeremy#{$c1}@#{$c2}mystix#{$c1}.#{$c2}org"
                puts "   AIM#{$c1}:#{$c2} d34d0"
                puts "   MSN#{$c1}:#{$c2} imdeado#{$c1}@#{$c2}gmail#{$c1}.#{$c2}com"
                puts "   IRC#{$c1}:#{$c2} irc#{$c1}.#{$c2}freenode#{$c1}.#{$c2}net #{$c1}##{$c2}gentoo.et"
        end
        def Menu.quit
                #ends our program; i could just use 'exit' here.. but, this works just as well
                $EndProg = true
        end
        def Menu.detach
                #detach the 'screen' session, figured it was a nice addon
                `screen -d`
        end
        def Menu.colors
                #this section is comming soon ffs
	                puts "#{$head}This option allows you to change script colours and boldness..."
	                puts "   Now, there will not be a list or a chart to show you the colors..."
	                puts "   so you just kinda have to know what you are doing here. Enjoy!"
	                sc1 = $c1.slice($c1.index("[")+1, $c1.length)
	                sc2 = $c2.slice($c2.index("[")+1, $c2.length)
	                sc3 = $c3.slice($c3.index("[")+1, $c3.length)
	                print " New Color 1#{$c1}(#{$c2}#{sc1}#{$c1}):#{$c2} "
	                tmp1 = gets.strip
	                print " New Color 2#{$c1}(#{$c2}#{sc2}#{$c1}):#{$c2} "
	                tmp2 = gets.strip
	                print " New Color 3#{$c1}(#{$c2}#{sc3}#{$c1}):#{$c2} "
	                tmp3 = gets.strip
	                $c1 = "\033[#{tmp1}" if tmp1 != ""
	                $c2 = "\033[#{tmp2}" if tmp2 != ""
	                $c3 = "\033[#{tmp3}" if tmp3 != ""
        end
end

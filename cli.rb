require_relative "lib/repositories"

repositories = Repositories.new

prompt = "\nEnter the name of the GitHub user you're interested in (type 'q' to quit): "

print prompt

begin
  while (user = gets.chomp) != "q" # type 'q' to quit
    begin
      result = repositories.fetch(user)

      if result.empty?
        puts "\nSorry, it looks like #{user} doesn't have any repositories."
      else
        puts "\nHere are #{user}'s repositories:\n\n"
        puts result
      end

      print prompt
    rescue Faraday::Error::ClientError # connection error
      puts "I couldn't connect to the server. Please check your internet connection and try again."

      print prompt
    rescue StandardError # bad input
      puts "I'm sorry, I didn't understand that. Please try again."

      print prompt
    end
  end

  puts "Goodbye!"
rescue SystemExit, Interrupt # exit gracefully with Ctrl-C
  puts "\nGoodbye!"
end

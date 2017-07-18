# An instance of this class speaks directly to a IO object.
module YouTubeList
  class Logger

    def initialize
      @logs = []
    end

    # @param string [String].
    def puts(string)
      @logs << string
      write_logs()
    end

    private

    # Write all logs in database to the standard output.
    def write_logs
      # clean the console
      system('cls')
      # write each log again
      @logs.each do |log|
        $stdout.puts(log)
      end
    end
  end
end
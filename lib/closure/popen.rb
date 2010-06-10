module Closure

  # A slightly modified version of Ruby 1.8's Open3, that doesn't use a
  # grandchild process, and returns the pid of the external process.
  module Popen

    def self.popen(*cmd)
      # pipe[0] for read, pipe[1] for write
      pw, pr, pe = IO.pipe, IO.pipe, IO.pipe

      pid = fork {
        pw[1].close
        STDIN.reopen(pw[0])
        pw[0].close

        pr[0].close
        STDOUT.reopen(pr[1])
        pr[1].close

        pe[0].close
        STDERR.reopen(pe[1])
        pe[1].close

        exec(*cmd)
      }

      pw[0].close
      pr[1].close
      pe[1].close
      pi = [pw[1], pr[0], pe[0]]
      pw[1].sync = true
      begin
        if block_given?
          yield(*pi)
        end
      ensure
        pi.each{|p| p.close unless p.closed?}
      end
      pid
    end

  end
end

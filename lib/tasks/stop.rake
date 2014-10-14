desc 'Stop Rails server'
# from: http://stackoverflow.com/a/10747618
task :stop do
    pid_file = 'tmp/pids/server.pid'
    pid = File.read(pid_file).to_i
    Process.kill "INT", pid
    File.delete pid_file
end
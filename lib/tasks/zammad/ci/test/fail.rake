namespace :zammad do

  namespace :ci do

    namespace :test do

      desc 'Stops all of Zammads services and exists the rake task with exit code 1'
      task :fail, [:no_app] do |_task, args|
        Rake::Task['zammad:ci:test:stop'].invoke if args[:no_app].blank?
        abort('Abort further test processing')
      end
    end
  end
end

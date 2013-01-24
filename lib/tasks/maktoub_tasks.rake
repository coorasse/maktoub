namespace :maktoub do
  desc "send :newsletter to the configured from address"
  task :test, [:newsletter] => [:environment] do |t, args|
    if NewsletterMailer.method_defined? :delay
      NewsletterMailer.delay(:priority => 5, :queue => 'maktoub').publish(args[:newsletter], :email => Maktoub.from, :name => 'Tester')
      puts "delayed #{Maktoub.from}"
    else
      NewsletterMailer.publish(args[:newsletter], :email => Maktoub.from, :name => 'Joe Tester').deliver
      puts "delivered #{Maktoub.from}"
    end
  end

  desc "send :newsletter to all subscribers"
  task :mail, [:newsletter] => [:environment] do |t, args|
    puts "starting..."
    messages = Maktoub.subscribers.map do |u|
      if NewsletterMailer.method_defined? :delay
        NewsletterMailer.delay(:priority => 5, :queue => 'maktoub').publish(args[:newsletter], :email => u.send(Maktoub.email_field), :name => u.send(Maktoub.name_field))
        "delayed #{u.send Maktoub.email_field}"
      else
        NewsletterMailer.publish(args[:newsletter], :email => u.send(Maktoub.email_field), :name => u.send(Maktoub.name_field)).deliver
        "delivered #{u.send Maktoub.email_field}"
      end
    end
    puts "#{messages.length} messages"
    puts messages.join("\n")
  end
end


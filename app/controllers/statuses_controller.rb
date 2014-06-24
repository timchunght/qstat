class StatusesController < ApplicationController


  def index
    @status = Status.new
  end

  def detail
    if status_params == false
      redirect_to(:action => 'index')
    else
      @status = Status.new(status_params)
      #put this in index.html.erb <% @cmd.lines.each do |line|%> <td><%= line %></td> <% end %>
      #@cmd = #%x[ ssh -X timc@fred.cchem.berkeley.edu ] 
      @hostname = "dino.cchem.berkeley.edu"
      @username = @status.user_name #Not saved in database
      @password = @status.password #Not saved in database
      @cmd = "qstat"
      @job_id = Array.new
      @prior = Array.new
      @name = Array.new
      @user = Array.new
      @state = Array.new
      @submit_date = Array.new
      @submit_time = Array.new
      @queue = Array.new
      @slots = Array.new
      @file_locs = Array.new
      @running_locs = Array.new
      @tasks_info = Array.new

      begin
        ssh = Net::SSH.start(@hostname, @username, :password => @password)
        res = ssh.exec!(@cmd)
        #ssh.close
        @output = res
      rescue
        @output = "Unable to connect to #{@hostname} using #{@username} and your password input"
      end

      
      if @output == "Unable to connect to #{@hostname} using #{@username} and your password input"
        @output = @output
      else
        @output.lines[2..@output.lines.count].each do |line|

          if line.split(" ")[3].to_s == @status.user_name
            @job_id << line.split(" ")[0]
            @prior << line.split(" ")[1]
            @name << line.split(" ")[2]
            @user << line.split(" ")[3]
            @state << line.split(" ")[4]
            @submit_date << line.split(" ")[5]
            @submit_time << line.split(" ")[6]
            @queue << line.split(" ")[7]
            @slots << line.split(" ")[8]
          
          end
        end

        if @name.length == 0
          @output = false
          ssh.close
          
        else
        
          @output2 = ssh.exec!("find")



          @output2.lines.each do |line|
            @file_locs << line
          end

          @job_id.each do |id|
            @running_locs << @file_locs.select {|s| s.include? id.to_s}.to_s
          end

          @running_locs.each do |loc|
            @location = (extract_file_dir(loc) + "/" + extract_file_name(loc) + ".out").to_s
            if @location[0...1] == "/"
              @location = @location[1...@location.length]
              @tasks_info << ssh.exec!("ll " + @location)
            else
              @tasks_info << ssh.exec!("ll " + @location)
            end
          end

          ssh.close

        end


      end

    end
    

 
    #%x[ perl ~/Desktop/patmatch_1.2/patmatch.pl -n GNATATNC ~/Desktop/patmatch_1.2/step-1-Brassica1kb5primeupstreamfasta.faa 0 i ]

  end

  def new
  end

  def show
  end

  def edit
  end

  def delete
  end


  private

  def status_params
    
    begin
      params.require(:status).permit(:user_name, :password)
    rescue
      return false
    end
  
  end



  def extract_file_name(string)
    array = string.split("/")
    return string.split("/")[array.length-1].split(".")[0].to_s #this gives the file name; for example "./gaussian/vco.job.o189868" returns "vco"
    
  end

  def extract_file_dir(string)
    array = string.split("/")
    array.delete_at(0)
    array.delete_at(array.length-1)
    return array.join('/').to_s
  end
end


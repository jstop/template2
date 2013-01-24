require_relative 'models'
require_relative 'mailer'
#require_relative 'omniauth_keys'

class App < Sinatra::Application

  get '/schedule' do
    if logged_in?
      @routines = Routine.where(:user_id => current_user.id).all
      haml :user_routines
    else
      redirect '/signup'
    end
  end

  post '/signup/?' do
    params[:user]["token"] = SecureRandom.uuid
    puts params
    @user = User.set(params[:user])
    p @user.errors
    if @user.valid && @user.id
      #session[:user] = @user.id
      Notifier.welcome(@user).deliver
      if Rack.const_defined?('Flash')
        flash[:notice] = "Account created. Check your email for confirmation."
      end
      redirect '/validation_required'
    else
      if Rack.const_defined?('Flash')
        flash[:error] = "There were some problems creating your account: #{@user.errors}."
      end
      redirect '/signup?' + hash_to_query_string(params['user'])
    end
  end

  post '/login/?' do
    if user = User.authenticate(params[:email], params[:password])
      if user.validated?
        session[:user] = user.id
      else 
        redirect '/validation_required'
      end

      if Rack.const_defined?('Flash')
        flash[:notice] = "Login successful."
      end

      if session[:return_to]
        redirect_url = session[:return_to]
        session[:return_to] = false
        redirect redirect_url
      else
        redirect '/'
      end
    else
      if Rack.const_defined?('Flash')
        flash[:error] = "The email or password you entered is incorrect."
      end
      redirect '/login'
    end
  end
  get '/mail' do
    email = Notifier.welcome(current_user)
    email.deliver
    redirect '/'
  end

  get '/validation_required' do 
    haml :validation_required
  end

  post '/email_validation' do
    @user = MmUser.where(:email => params[:email]).first
    email = Notifier.welcome(@user)
    email.deliver
    redirect '/'
  end
  
  get '/token/:token' do |token|
    user = MmUser.first({token: token})
    @id = user.id
    if user
      #user.token="confirmed"
      user.set(:token => 'confirmed')
      user.save
      p user
      p user.errors
      session[:user] = user.id
      redirect '/'
    end
    user = MmUser.find(@id)
    haml :validation_required
  end
  
  get '/' do
    haml :home
  end

  get '/browse' do
    @routines = Routine.all
    @users = MmUser.where({permission_level: 1}).sort(:points.desc).limit(3)
    haml :browse
  end

  get '/filtered' do
      tag_ids = params[:tokens].split(",")
      @tags = []
      tag_ids.each do |tag|
        @tags << Tag.find(tag).name
      end
      puts @tags
      @routines = Routine.all(:tags => @tags)
      puts @routines
      @routines.each do |routine|
        puts routine.purpose
      end
    haml :filtered
  end

  get '/view_routine/:id' do |id|
    @routine = Routine.find(id)
    haml :routine
  end

  post '/routine/comment' do
    if logged_in?
      params["commentor"] = current_user.id
      params["commentor_name"] = current_user.name 
      r = Routine.find(params[:routine_id])
      c = Comment.new(params)
      r.comments << c
      r.save
    end
    redirect "/view_routine/#{params[:routine_id]}"
  end

  post '/routine/vote_up' do
    if logged_in?
      r = Routine.find(params[:routine_id])
      r.add_vote!(1, current_user)
      p r.errors
    end
    redirect "/view_routine/#{params[:routine_id]}"
  end

  post '/routine/vote_down' do
    if logged_in?
      r = Routine.find(params[:routine_id])
      r.add_vote!(-1, current_user)
      r.votes.each do |vote|
        p vote.errors
      end
    end
    redirect "/view_routine/#{params[:routine_id]}"
  end

  get '/view_users' do
    @routines = Routine.all
    @users = MmUser.all
    if logged_in? && current_user.admin?
      haml :view_users
    else
      redirect '/'
    end
  end

  get '/view_user/:id' do
    @user = MmUser.find(params[:id])
    @routines = Routine.where(user_id: params[:id]).fields(:name).all
    @routines.each do |routine|
      puts routine.title
    end
    haml :user
  end

  get '/build_tag' do
    @tags= Tag.all
    haml :tag_form
  end
  
  get '/tags_service' do
    Tag.all.to_json
  end

  post '/build_tag' do
    puts params
    tag = Tag.create(params)
    tag.save
    puts tag
    redirect '/build_tag'
  end

  get '/build' do
    if logged_in?
      haml :user_routine_form
    else
      haml :anonymous_instant_build_routine_form
    end
  end

  get '/instant_build' do
    puts params
    haml :instant_routine
  end
  
  get '/instant_build_ics' do
    puts params
    calendar = RiCal.Calendar do
      event do
        description "hello" 
        dtstart     Time.now.with_floating_timezone
        rrule       :freq => "WEEKLY", :until => Time.now + 1.month, :byday => ['MO', 'WE', 'FR']
      end
    end
    File.open("../ui/public/routine.ics", 'w') {|f| f.write(calendar.to_s) }
    send_file('../ui/public/routine.ics', :type => "text/calendar", :filename => File.basename('routine.ics'))
  end

  post '/build' do
    if logged_in?
      tag_ids = params[:tokens].split(",")
      params.delete("tokens")
      params[:user_name] = current_user.name
      r = Routine.new(params)
      tag_ids.each do |tag_id|
        r.tags << Tag.find(tag_id).name
      end
      r.user_id = current_user.id
      r.save
    end
      redirect '/'
  end

  post '/token_params' do
    tag_ids = params[:tokens].split(",")
    puts tag_ids
    tag_ids.each do |tag_id|
      puts Tag.find(tag_id).name
    end
    redirect '/build_tag'
  end
end

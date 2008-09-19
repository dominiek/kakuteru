
require 'mechanize'

def vote
  agent = WWW::Mechanize.new
  user_agents = ['Windows IE 6', 'Windows IE 7', 'Windows Mozilla', 'Mac Safari', 'Mac FireFox', 'Mac Mozilla']
  random_user_agent = user_agents[(rand * user_agents.size).floor]
  agent.user_agent_alias = random_user_agent
  page = 

end

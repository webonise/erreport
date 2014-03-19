Rails.application.routes.draw do
  match '*a', :to => 'project106/error#routing'
end
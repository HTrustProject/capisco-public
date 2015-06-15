Rails.application.routes.draw do

  # ruby on rails will add CRUD restful URLS (index, show, new, create, edit, update, destroy) for resources
  # but we add the custom GET export action to every workset of worksets
  # http://guides.rubyonrails.org/routing.html
  resources :worksets do
		member do
			get 'export'
			put 'deselect'
				# See http://guides.rubyonrails.org/routing.html, section "2.10.1 Adding Member Routes":
				# The put 'deselect' line, creates deselect_workset_url and deselect_workset_path helpers, the latter being /workset/id/deselect/
				# full url we'll build is of the form workset/id/deselect/?docid=..
			get 'senseFrequencies'
		end
	end
  resources :users

  # http://stackoverflow.com/questions/25586310/rake-route-error-missing-action-key-on-routes-definition
  post 'queryterms/saveQueryterms' => 'queryterms#saveQueryterms'
  post 'worksets/saveSearchResults/:id' => 'worksets#saveSearchResults'


  post 'search_results/results'
  get 'search_results/returnAJSON'
  get 'search_results/returnMetadataAJSON'

  root 'static_pages#semanticsearch'
  get 'static_pages/index'
  get 'static_pages' => 'static_pages#index'

  get 'static_pages/contextsadder'
  get 'static_pages/semanticsearch'
  get 'static_pages/newcontextadder'
  get 'static_pages/optionspage'


  get 'inlinks/inlinks'
  get 'outlinks/outlinks'
  get 'synonyms/getSynonyms'
  get 'search/results'
  get 'get_doc/get_document'
  get 'get_metadata/get_metadata'
  get 'contextsadder/get'
  get '/contextsadder/getNewJson'

  get 'semantic_search/getJson'
  get 'semantic_search/getOwlJson'

  get 'context_page_gen/listOfContexts'

  get 'searchresults/show' => 'search_results#show', as: 'path_search_results'

  get 'concepts' => 'concepts#index', as: 'path_show_concepts'
  get 'concepts/visualize' => 'concepts#visualize', as: 'path_visualize_concepts'

  get 'links/synonyms' => 'links#synonyms', as: 'path_show_synonyms'
  get 'links/senses' => 'links#senses', as: 'path_show_senses'
  get 'links/inlinks' => 'links#inlinks', as: 'path_show_inlinks'
  get 'links/outlinks' => 'links#outlinks', as: 'path_show_outlinks'
  get 'links/synmaps' => 'links#synmaps', as: 'path_show_synmaps'
  get 'links/keymaps' => 'links#keymaps', as: 'path_show_keymaps'
  get 'links/mappings' => 'links#mappings', as: 'path_show_mappings'
  get 'links/contexts' => 'links#contexts', as: 'path_show_contexts'

  post '/basket_items/add'

  get ':controller(/:action(/:id))'
end

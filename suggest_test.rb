User.__elasticsearch__.client.suggest(:index => Article.index_name, :body => {
        :suggestions => {
            :text => "s",
            :completion => {
                :field => 'suggest'
            }
        }
    })

pp User.__elasticsearch__.client.suggest(index: User.index_name, body: {
  suggestions: {
      text: User.first.name.split(' ').first,
      completion: {
        field: 'suggest'
      }
  }
})

pp User.__elasticsearch__.client.suggest(index: User.index_name, body: {
  suggestion: {
      text: 'm',
      completion: {
        field: 'suggest'
      }
  }
})


curl -X POST 'localhost:9200/urug_elasticsearch_users/_suggest?pretty' -d '{
    "song-suggest" : {
        "text" : "Lorenza",
        "completion" : {
            "field" : "suggest"
        }
    }
}'

User.__elasticsearch__.client.search( { body: { query: { match: { quote: 'used' } } } }).first

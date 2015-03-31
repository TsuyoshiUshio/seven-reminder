json.array!(@vocabularies) do |vocabulary|
  json.extract! vocabulary, :id, :name, :definition, :example, :url, :confirmed
  json.url vocabulary_url(vocabulary, format: :json)
end

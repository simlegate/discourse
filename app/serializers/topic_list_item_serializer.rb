class TopicListItemSerializer < ListableTopicSerializer

  attributes :views,
             :like_count,
             :starred,
             :has_summary,
             :archetype,
             :last_poster_username,
             :category_id

  has_many :posters, serializer: TopicPosterSerializer, embed: :objects
  has_many :participants, serializer: TopicPosterSerializer, embed: :objects

  def starred
    object.user_data.starred?
  end

  alias :include_starred? :has_user_data

  def posters
    object.posters || []
  end

  def last_poster_username
    object.posters.find { |poster| poster.user.id == object.last_post_user_id }.try(:user).try(:username)
  end

  def participants
    object.participants_summary || []
  end

  def include_participants?
    object.private_message?
  end

end

module RightScaleAPI
  class RightScript <  Account::SubResource
    attributes %w(
      created_at
      description
      name
      script
      updated_at
      href
      version
      is_head_version
    )
  end
end

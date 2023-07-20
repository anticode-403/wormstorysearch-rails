class StoriesPresenter < ApplicationPresenter
  presenter_options.presents = :story

  # label
  define_extension(:label, :title_label,       :title,  content: "Title")
  define_extension(:label, :author_label,      :author_id, content: "Author")
  define_extension(:label, :status_label,      :description, content: "Status")
  define_extension(:label, :crossover_label,   :crossover, content: "Crossover/Information")
  define_extension(:label, :description_label, :description, content: "Description")
  define_extension(:label_for, :merge_with_story_label, :merge_with_story_id, content: "Merge With:")
  # text_field
  define_extension(:text_field, :title_field,     :title, placeholder: "Messages from an Angel")
  define_extension(:text_field, :author_field,    :author, placeholder: "Ack")
  define_extension(:text_field, :crossover_field, :crossover, placeholder: "Justice League")
  # text_area
  define_extension(:text_area,  :description_field, :description, placeholder: "Short overview about this story", rows: 5)
  # select
  define_extension(:select, :status_select, :status, content: Story.const.statuses.nest(:label, :status))
  # check_box
  define_extension(:check_box, :is_nsfw_check_box, :is_nsfw)
  define_extension(:check_box, :is_archived_check_box, :is_archived)
  # span_tag
  define_extension(:span_tag, :is_nsfw_check_box_text, content: "NSFW?")
  define_extension(:span_tag, :is_archived_check_box_text, content: "Archive this story?")
  # link_to
  define_extension(:span_tag, :edit_link, content: "")
  # filters
  define_extension(:text_field_tag, :rating_filter, :rating_filter, placeholder: "Rating", "aria-label" => "Rating")
  define_extension(:text_field_tag, :hype_rating_filter, :hype_rating_filter, placeholder: "Hype", "aria-label" => "Hype")
  define_extension(:text_field_tag, :word_count_filter, :word_count_filter, placeholder: "Words", "aria-label" => "Word Count")
  define_extension(:text_field_tag, :updated_after_filter, :updated_after_filter, placeholder: "MM/DD(/YY)", "aria-label" => "Updated After")
  define_extension(:text_field_tag, :updated_before_filter, :updated_before_filter, placeholder: "MM/DD(/YY)", "aria-label" => "Updated Before")
  define_extension(:text_field_tag, :created_after_filter, :created_after_filter, placeholder: "MM/DD(/YY)", "aria-label" => "Created After")
  define_extension(:text_field_tag, :created_before_filter, :created_before_filter, placeholder: "MM/DD(/YY)", "aria-label" => "Created Before")
  # sorters
  define_extension(:sorter_link, :story_created_on_sorter, "stories.story_created_on", content: "Created", default_direction: "desc")
  define_extension(:sorter_link, :title_sorter, "stories.title", content: "Title")
  define_extension(:sorter_link, :rating_sorter, "stories.rating", content: "Rating", default_direction: "desc")
  define_extension(:sorter_link, :hype_rating_sorter, "stories.hype_rating", content: "Hype", default_direction: "desc")
  define_extension(:sorter_link, :word_count_sorter,"stories.word_count", content: "Words", default_direction: "desc")

  # custom fields
  def story_filter(*params)
    text_field_tag(:story_keywords, *params, placeholder: "Title, Crossover, Author, or Description", "aria-label" => "Search")
  end

  def story_updated_at_sorter
    sorter_link("stories.story_updated_at", default_direction: "desc") do
      span_tag(add_class: "hidden-sm hidden-xs") { "Updated" } +
      span_tag(add_class: "hidden-md hidden-lg", title: "Updated", "aria-label" => "Updated") { icon("calendar") }
    end
  end

  def author_select(params = {})
    authors = StoryAuthor.pluck(:name, :id)
    select(:author_id, content: authors, prompt: "Author", add_class: "select2")
  end

  def merge_with_story_select(params = {})
    story = extract_record(params)
    stories = Story.preload(:author).select(:id, :title, :crossover, :author_id).seek(id_not_eq: story.id).map do |story|
      ["#{story.crossover_title.inspect} by #{story.author_name}", story.id]
    end
    select_tag(:merge_with_story_id, content: stories, prompt: "Find story...", add_class: "select2")
  end

  # html
  def index_link(*hashes, &content_block)
    default_content = icon_content(*hashes, icon: "list", content: "Stories")
    link_to(view.stories_path, *hashes, content: default_content, &content_block)
  end
  define_extension(:index_link, :index_link_btn, add_class: "btn btn-default")

  def show_link(*hashes, &content_block)
    story = extract_record(*hashes)
    default_content = icon_content(*hashes, icon: "list", content: "Show")
    link_to(view.story_path(story), *hashes, content: default_content, &content_block)
  end
  define_extension(:show_link, :show_link_btn, add_class: "btn btn-default")

  def edit_link(*hashes, &content_block)
    story = extract_record(*hashes)
    default_content = icon_content(*hashes, icon: "edit", content: "Edit")
    if view.is_admin?
      link_to(view.edit_story_path(story), *hashes, content: default_content, &content_block)
    end
  end
  define_extension(:edit_link, :edit_link_btn, add_class: "btn btn-default")

  def read_link(*hashes, &content_block)
    story = extract_record(*hashes)
    default_content = icon_content(*hashes, icon: "external-link", content: "Read")
    tab_link(
      story.read_url,
      *hashes,
      content: default_content,
      data: { track: click_track_path(story) },
      &content_block
    )
  end
  define_extension(:read_link, :read_link_btn, add_class: "btn btn-primary")

  def modal_show_link(*hashes, &content_block)
    story = extract_record(*hashes)
    default_content = icon_content(*hashes, icon: "list", content: "Show")
    dynamic_modal_link(
      view.story_path(story),
      *hashes,
      title: "View details",
      merge_data: { toggle: "desktop-tooltip" },
      content: default_content,
      &content_block
    )
  end
  define_extension(:modal_show_link, :modal_show_link_btn, add_class: "btn btn-default")

  def modal_edit_link(*hashes, &content_block)
    story = extract_record(*hashes)
    default_content = icon_content(*hashes, icon: "edit", content: "Edit")
    if view.is_admin?
      dynamic_modal_link(
        view.edit_story_path(story),
        *hashes,
        title: "Edit details",
        merge_data: { toggle: "desktop-tooltip" },
        content: default_content,
        &content_block
      )
    end
  end
  define_extension(:modal_edit_link, :modal_edit_link_btn, add_class: "btn btn-default")

  def row_alert_class(*hashes)
    story = extract_record(*hashes)
    story.recently_created? ? "info" : ""
  end

  def created_icon(*hashes, &content_block)
    story = extract_record(*hashes)
    tooltip_content = "Created #{moment_span(story.story_created_on, :calendar_full)}".html_safe
    icon(
      "calendar-plus",
      title: "Created #{moment_span(story.story_created_on, :calendar_full)}",
      "aria-label" => story.story_created_on.to_calendar_full_s(full_month: true),
      data: { toggle: "tooltip", placement: "top auto", trigger: "hover", content: tooltip_content, html: "true" }
    )
  end

  def location_rating(location)
    location_rating = location.rating.to_i
    alternate_ratings =
      case location.const.location_slug.verify_in!(%w[ spacebattles sufficientvelocity fanfiction archiveofourown questionablequesting ])
      when "spacebattles"         then ["#{location.highest_chapter_likes.to_i} High", "#{location.average_chapter_likes.to_i} Avg"]
      when "sufficientvelocity"   then ["#{location.highest_chapter_likes.to_i} High", "#{location.average_chapter_likes.to_i} Avg"]
      when "fanfiction"           then ["#{location.favorites} Favs"]
      when "archiveofourown"      then ["#{location.kudos} Kudos"]
      when "questionablequesting" then ["#{location.highest_chapter_likes.to_i} High", "#{location.average_chapter_likes.to_i} Avg"]
      end
    alternate_ratings.map! do |alternate_rating|
      em_tag(content: "(#{alternate_rating})")
    end
    content = [location_rating, *alternate_ratings].join(" ").html_safe
    span_tag(content: content, style: "white-space: nowrap;")
  end

  def rating_details(*hashes)
    story = extract_record(*hashes)
    location_ratings = story.locations.map do |location|
      case location.const.location_slug.verify_in!(%w[ spacebattles sufficientvelocity fanfiction archiveofourown questionablequesting ])
      when "spacebattles"
        "#{location.const.location_abbreviation}: #{location.rating.to_i} (#{location.highest_chapter_likes.to_i} High) (#{location.average_chapter_likes.to_i} Avg)"
      when "sufficientvelocity"
        "#{location.const.location_abbreviation}: #{location.rating.to_i} (#{location.highest_chapter_likes.to_i} High) (#{location.average_chapter_likes.to_i} Avg)"
      when "fanfiction"
        "#{location.const.location_abbreviation}: #{location.rating.to_i} (#{location.favorites} Favs)"
      when "archiveofourown"
        "#{location.const.location_abbreviation}: #{location.rating.to_i} (#{location.kudos} Kudos)"
      when "questionablequesting"
        "#{location.const.location_abbreviation}: #{location.rating.to_i} (#{location.highest_chapter_likes.to_i} High) (#{location.average_chapter_likes.to_i} Avg)"
      end
    end
    location_ratings.unshift("Highly Rated!") if story.highly_rated?
    location_ratings_content = location_ratings.map { |content| span_tag(content: content.strip, style: "white-space: nowrap;") }.join(br_tag)
    send(story.highly_rated? ? :strong_tag : :span_tag,
      *hashes,
      content: story.rating.to_i,
      title: location_ratings_content,
      add_class: "tooltip-text-left",
      merge_data: { toggle: "tooltip", trigger: "hover", html: true }
    )
  end

  def hype_rating_details(*hashes)
    story = extract_record(*hashes)
    popover_content = []
    popover_content.unshift("Highly Hyped!") if story.highly_hyped?
    popover_content.push("Hype decays quickly over time")
    popover_content.push("Formula: rating * 20 / age (days)")
    popover_content = popover_content.map { |content| span_tag(content: content.strip, style: "white-space: nowrap;") }.join(br_tag)
    send(
      story.highly_hyped? ? :strong_tag : :span_tag,
      *hashes,
      title: popover_content,
      add_class: "tooltip-text-left",
      merge_data: { toggle: "tooltip", trigger: "hover", html: true },
      content: story.hype_rating.to_i,
    )
  end

  def click_track_path(story)
    if story.is_a?(Story)
      view.clicked_story_path(story)
    else
      view.clicked_story_path(story.story_id, location_model: story.class.name, location_id: story.id)
    end
  end

end

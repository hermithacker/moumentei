# -*- coding: utf-8 -*-
class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_save(article)
    article.clear_related_caches
    expire_fragment [article.group, 'counts']
    expire_fragment 'groups_count'
  end

  def before_destroy(article)
    
    on_delete(article)
    article.clear_related_caches
    #Notification.delete_all :key => "new_comment.#{r.id}"
  end

  def on_delete(r)
    a = r.group.root
    expire_fragment [r.group, 'counts']
    expire_fragment 'groups_count'
    if r.next_in_group(a.id)
      i = r.next_in_group(a.id)
      Rails.cache.delete("article_prev/#{a.id}/#{i}")
    end

    if r.prev_in_group(a.id)
      i = r.prev_in_group(a.id)
      Rails.cache.delete("article_next/#{a.id}/#{i}")
    end

    Rails.cache.delete "Article/#{r.id}"
  end
end

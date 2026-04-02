document.addEventListener('DOMContentLoaded', function() {
  const searchInput = document.getElementById('search-input');
  const searchResults = document.getElementById('search-results');
  const searchButton = document.getElementById('search-button');
  let searchIndex = null;
  let documents = [];

  function loadSearchIndex() {
    fetch('/search.json')
      .then(response => response.json())
      .then(data => {
        documents = data;
        searchIndex = lunr(function() {
          this.ref('url');
          this.field('title', { boost: 10 });
          this.field('content');
          this.field('tags');
          this.field('categories');
          
          documents.forEach(function(doc) {
            this.add(doc);
          }, this);
        });
      })
      .catch(error => console.error('Error loading search index:', error));
  }

  function performSearch(query) {
    if (!searchIndex || !query.trim()) {
      searchResults.innerHTML = '';
      return;
    }

    const results = searchIndex.search(query);
    displayResults(results);
  }

  function displayResults(results) {
    if (results.length === 0) {
      searchResults.innerHTML = '<div class="no-results">没有找到相关文章</div>';
      return;
    }

    const html = results.map(result => {
      const doc = documents.find(d => d.url === result.ref);
      if (!doc) return '';
      
      const excerpt = doc.excerpt || doc.content.substring(0, 150) + '...';
      const date = doc.date ? new Date(doc.date).toLocaleDateString('zh-CN') : '';
      const tags = doc.tags ? doc.tags.map(tag => '<span class="result-tag">' + tag + '</span>').join('') : '';
      
      return '<div class="search-result-item">' +
        '<a href="' + doc.url + '" class="result-title">' + highlightText(doc.title, searchInput.value) + '</a>' +
        '<div class="result-meta">' +
        (date ? '<span class="result-date">' + date + '</span>' : '') +
        tags +
        '</div>' +
        '<p class="result-excerpt">' + excerpt + '</p>' +
        '</div>';
    }).join('');

    searchResults.innerHTML = html;
  }

  function highlightText(text, query) {
    if (!query) return text;
    const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regex = new RegExp('(' + escapedQuery.split(' ').join('|') + ')', 'gi');
    return text.replace(regex, '<mark>$1</mark>');
  }

  let debounceTimer;
  searchInput.addEventListener('input', function() {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      performSearch(this.value);
    }, 300);
  });

  searchButton.addEventListener('click', function() {
    performSearch(searchInput.value);
  });

  searchInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
      performSearch(this.value);
    }
  });

  document.addEventListener('click', function(e) {
    if (!e.target.closest('.search-container')) {
      searchResults.innerHTML = '';
    }
  });

  loadSearchIndex();
});
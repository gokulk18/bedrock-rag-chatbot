

(function () {
  'use strict';

  const API_ENDPOINT = window.CHATBOT_API_ENDPOINT || '/chat';

  const appShell       = document.getElementById('app-shell');
  const sidebar        = document.getElementById('sidebar');
  const sidebarToggle  = document.getElementById('sidebar-toggle');
  const topbarToggle   = document.getElementById('topbar-toggle');
  const newChatBtn     = document.getElementById('new-chat-btn');
  const historyList    = document.getElementById('history-list');
  const topbarTitle    = document.getElementById('topbar-title');
  const clearChatBtn   = document.getElementById('clear-chat-btn');
  const welcomeScreen  = document.getElementById('welcome-screen');
  const msgContainer   = document.getElementById('messages-container');
  const chatForm       = document.getElementById('chat-form');
  const userInput      = document.getElementById('user-input');
  const sendBtn        = document.getElementById('send-btn');

  let sessions   = {};
  let activeId   = null;
  let isStreaming = false;

  function saveSessions()  { localStorage.setItem('nova_sessions', JSON.stringify(sessions)); }
  function loadSessions()  {
    try { sessions = JSON.parse(localStorage.getItem('nova_sessions') || '{}'); } catch { sessions = {}; }
  }

  function createSession() {
    const id = 'sess-' + Date.now() + '-' + Math.random().toString(36).slice(2, 7);
    sessions[id] = { title: 'New conversation', messages: [] };
    saveSessions();
    return id;
  }

  function switchSession(id) {
    activeId = id;
    renderMessages();
    renderHistory();
    topbarTitle.textContent = sessions[id]?.title || 'New conversation';
    const hasMessages = sessions[id]?.messages?.length > 0;
    welcomeScreen.style.display = hasMessages ? 'none' : '';
    msgContainer.style.display  = hasMessages ? '' : 'none';
  }

  function autoTitleSession(id, firstUserText) {
    if (!sessions[id]) return;
    const title = firstUserText.length > 45
      ? firstUserText.slice(0, 42) + '…'
      : firstUserText;
    sessions[id].title = title;
    saveSessions();
    if (id === activeId) topbarTitle.textContent = title;
    renderHistory();
  }

  function renderHistory() {
    historyList.innerHTML = '';
    const ids = Object.keys(sessions).reverse();

    if (ids.length === 0) {
      historyList.innerHTML = '<p class="history-empty">No conversations yet</p>';
      return;
    }

    ids.forEach(id => {
      const sess  = sessions[id];
      const item  = document.createElement('div');
      item.className = 'history-item' + (id === activeId ? ' active' : '');
      item.dataset.id = id;

      const lastMsg = sess.messages[sess.messages.length - 1];
      const timeStr = lastMsg
        ? new Date(lastMsg.time).toLocaleDateString(undefined, { month: 'short', day: 'numeric' })
        : 'Just now';

      item.innerHTML = `
        <span class="history-item-title">${escHtml(sess.title)}</span>
        <span class="history-item-time">${timeStr}</span>
      `;
      item.addEventListener('click', () => switchSession(id));
      historyList.appendChild(item);
    });
  }

  function renderMessages() {
    msgContainer.innerHTML = '';
    const sess = sessions[activeId];
    if (!sess) return;
    sess.messages.forEach(m => appendBubble(m.role, m.text, m.time, m.citations, false));
    scrollToBottom();
  }

  function scrollToBottom() {
    const area = document.getElementById('chat-area');
    if (area) area.scrollTop = area.scrollHeight;
  }

  function appendBubble(role, text, time, citations, animate = true) {
    const row = document.createElement('div');
    row.className = `msg-row ${role}`;
    if (!animate) row.style.animation = 'none';

    const avatar = document.createElement('div');
    avatar.className = 'msg-avatar';
    avatar.textContent = role === 'user' ? '🧑' : '✦';

    const wrap   = document.createElement('div');
    wrap.className = 'msg-bubble-wrap';

    const bubble = document.createElement('div');
    bubble.className = 'msg-bubble';
    bubble.textContent = text;
    wrap.appendChild(bubble);

    if (citations && citations.length > 0) {
      const sources = new Set();
      citations.forEach(c => {
        (c.retrievedReferences || []).forEach(ref => {
          const uri = ref?.location?.s3Location?.uri;
          if (uri) {
            const name = decodeURIComponent(uri.split('/').pop());
            if (name) sources.add(name);
          }
        });
      });
      if (sources.size > 0) {
        const pillRow = document.createElement('div');
        pillRow.className = 'sources-row';
        sources.forEach(name => {
          const pill = document.createElement('span');
          pill.className = 'source-pill';
          pill.textContent = '📄 ' + name;
          pill.title = name;
          pillRow.appendChild(pill);
        });
        wrap.appendChild(pillRow);
      }
    }

    const timeEl = document.createElement('div');
    timeEl.className = 'msg-time';
    timeEl.textContent = formatTime(time || Date.now());
    wrap.appendChild(timeEl);

    if (role === 'ai') {
      row.appendChild(avatar);
      row.appendChild(wrap);
    } else {
      row.appendChild(wrap);
      row.appendChild(avatar);
    }

    msgContainer.appendChild(row);
    scrollToBottom();
    return row;
  }

  function appendTypingIndicator() {
    const row = document.createElement('div');
    row.className = 'msg-row ai';
    row.id = 'typing-indicator';

    const avatar = document.createElement('div');
    avatar.className = 'msg-avatar';
    avatar.textContent = '✦';

    const wrap = document.createElement('div');
    wrap.className = 'msg-bubble-wrap';

    const bubble = document.createElement('div');
    bubble.className = 'msg-bubble';
    bubble.innerHTML = '<div class="typing-dots"><span></span><span></span><span></span></div>';
    wrap.appendChild(bubble);

    row.appendChild(avatar);
    row.appendChild(wrap);
    msgContainer.appendChild(row);
    scrollToBottom();
    return row;
  }

  async function sendMessage(prompt) {
    if (!prompt.trim() || isStreaming) return;
    isStreaming = true;
    sendBtn.disabled = true;

    welcomeScreen.style.display = 'none';
    msgContainer.style.display  = '';

    const now = Date.now();

    sessions[activeId].messages.push({ role: 'user', text: prompt, time: now });
    if (sessions[activeId].messages.length === 1) autoTitleSession(activeId, prompt);
    saveSessions();

    appendBubble('user', prompt, now);

    const typingEl = appendTypingIndicator();

    try {
      const res  = await fetch(API_ENDPOINT, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ prompt, session_id: activeId }),
      });

      const data = await res.json();
      typingEl.remove();

      if (res.ok && data.answer) {
        const aiTime = Date.now();
        sessions[activeId].messages.push({
          role:      'ai',
          text:      data.answer,
          time:      aiTime,
          citations: data.citations || []
        });
        saveSessions();
        appendBubble('ai', data.answer, aiTime, data.citations || []);
      } else {
        const errText = (typeof data.error === 'string' && data.error)
          ? data.error
          : (data.message || 'Failed to get a response. Please try again.');
        appendBubble('ai', errText, Date.now());
      }
    } catch (err) {
      typingEl.remove();
      appendBubble('ai', 'Network error: ' + err.message, Date.now());
    } finally {
      isStreaming = false;
      sendBtn.disabled = !userInput.value.trim();
      userInput.focus();
      renderHistory();
    }
  }


  function formatTime(ts) {
    const d = new Date(ts);
    return d.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });
  }

  function escHtml(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }

  function resizeInput() {
    userInput.style.height = 'auto';
    userInput.style.height = Math.min(userInput.scrollHeight, 160) + 'px';
    sendBtn.disabled = !userInput.value.trim() || isStreaming;
  }

  function toggleSidebar() {
    appShell.classList.toggle('sidebar-collapsed');
  }

  sidebarToggle.addEventListener('click', toggleSidebar);
  topbarToggle.addEventListener('click', toggleSidebar);

  newChatBtn.addEventListener('click', () => {
    const id = createSession();
    switchSession(id);
  });

  clearChatBtn.addEventListener('click', () => {
    if (!activeId) return;
    if (!confirm('Clear this conversation?')) return;
    sessions[activeId].messages = [];
    sessions[activeId].title    = 'New conversation';
    saveSessions();
    switchSession(activeId);
  });

  chatForm.addEventListener('submit', async e => {
    e.preventDefault();
    const text = userInput.value.trim();
    if (!text) return;
    userInput.value = '';
    resizeInput();
    await sendMessage(text);
  });

  userInput.addEventListener('input', resizeInput);

  userInput.addEventListener('keydown', e => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      chatForm.dispatchEvent(new Event('submit'));
    }
  });

  document.querySelectorAll('.suggestion-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      const prompt = chip.dataset.prompt;
      if (prompt) sendMessage(prompt);
    });
  });

  function init() {
    loadSessions();

    const ids = Object.keys(sessions);
    if (ids.length > 0) {
      activeId = ids[ids.length - 1];
    } else {
      activeId = createSession();
    }

    renderHistory();
    switchSession(activeId);
    userInput.focus();
  }

  init();

})();

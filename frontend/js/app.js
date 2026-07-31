document.addEventListener('DOMContentLoaded', () => {
  const chatMessages = document.getElementById('chat-messages');
  const chatForm = document.getElementById('chat-form');
  const userInput = document.getElementById('user-input');
  const sendBtn = document.getElementById('send-btn');
  const sessionIdDisplay = document.getElementById('session-id-display');

  // Configure API endpoint (replaced during deployment or set via relative/config)
  const API_ENDPOINT = window.CHATBOT_API_ENDPOINT || '/chat';

  // Generate or retrieve persistent session ID
  let sessionId = localStorage.getItem('bedrock_rag_session_id');
  if (!sessionId) {
    sessionId = 'session-' + Math.random().toString(36).substring(2, 11);
    localStorage.setItem('bedrock_rag_session_id', sessionId);
  }
  sessionIdDisplay.textContent = sessionId;

  chatForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const prompt = userInput.value.trim();
    if (!prompt) return;

    // Display user message
    appendMessage(prompt, 'user');
    userInput.value = '';
    sendBtn.disabled = true;

    // Display typing indicator
    const typingIndicator = appendMessage('Thinking...', 'assistant', 'typing-indicator');

    try {
      const response = await fetch(API_ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: prompt, session_id: sessionId })
      });

      const data = await response.json();
      typingIndicator.remove();

      if (response.ok && data.answer) {
        appendMessage(data.answer, 'assistant', null, data.citations);
      } else {
        appendMessage(`Error: ${data.error || 'Failed to generate response.'}`, 'assistant');
      }
    } catch (err) {
      typingIndicator.remove();
      appendMessage(`Network error: ${err.message}`, 'assistant');
    } finally {
      sendBtn.disabled = false;
      userInput.focus();
    }
  });

  function appendMessage(text, sender, className = null, citations = null) {
    const msgDiv = document.createElement('div');
    msgDiv.classList.add('message', `${sender}-message`);
    if (className) msgDiv.classList.add(className);

    const contentDiv = document.createElement('div');
    contentDiv.classList.add('message-content');
    contentDiv.textContent = text;
    msgDiv.appendChild(contentDiv);

    if (citations && citations.length > 0) {
      const citationsDiv = document.createElement('div');
      citationsDiv.classList.add('citations-container');

      const title = document.createElement('div');
      title.classList.add('citations-title');
      title.textContent = 'Sources & Citations:';
      citationsDiv.appendChild(title);

      citations.forEach((c, idx) => {
        const card = document.createElement('div');
        card.classList.add('citation-card');

        let text = '';
        let docName = '';

        if (c.retrievedReferences && c.retrievedReferences.length > 0) {
          const ref = c.retrievedReferences[0];
          text = ref.content?.text || '';
          if (ref.location?.s3Location?.uri) {
            const uriParts = ref.location.s3Location.uri.split('/');
            docName = decodeURIComponent(uriParts[uriParts.length - 1]);
          }
        }

        if (!text && c.generatedResponsePart?.textResponsePart?.text) {
          text = c.generatedResponsePart.textResponsePart.text;
        }

        if (!text) {
          text = 'Document passage referenced';
        }

        const docLabel = docName ? `📄 Source: ${docName}` : `[Citation ${idx + 1}]`;
        
        const labelElem = document.createElement('div');
        labelElem.style.fontWeight = '600';
        labelElem.style.fontSize = '0.85rem';
        labelElem.style.color = '#a5b4fc';
        labelElem.style.marginBottom = '4px';
        labelElem.textContent = docLabel;

        const textElem = document.createElement('div');
        textElem.style.fontSize = '0.9rem';
        textElem.style.color = '#e2e8f0';
        textElem.style.lineHeight = '1.4';
        textElem.textContent = text;

        card.appendChild(labelElem);
        card.appendChild(textElem);
        citationsDiv.appendChild(card);
      });

      msgDiv.appendChild(citationsDiv);
    }

    chatMessages.appendChild(msgDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
    return msgDiv;
  }
});

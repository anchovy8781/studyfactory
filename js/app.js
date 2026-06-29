/**
 * app.js — 화면 전환 및 전체 흐름 제어
 */
(function () {
  // ───────── DOM 참조 ─────────
  const screens = {
    splash: document.getElementById('screen-splash'),
    permission: document.getElementById('screen-permission'),
    register: document.getElementById('screen-register'),
    auth: document.getElementById('screen-auth'),
    result: document.getElementById('screen-result'),
  };

  const loadingOverlay = document.getElementById('loading-overlay');
  const loadingText = document.getElementById('loading-text');

  let currentScreen = 'splash';
  let pendingAction = null; // 'register' | 'auth'
  let modelsReady = false;

  // ───────── 화면 전환 ─────────
  function showScreen(name) {
    const prev = screens[currentScreen];
    const next = screens[name];
    if (!next || currentScreen === name) return;

    prev?.classList.add('slide-out');
    setTimeout(() => {
      prev?.classList.remove('active', 'slide-out');
    }, 350);

    next.classList.add('active');
    currentScreen = name;
  }

  // ───────── 로딩 오버레이 ─────────
  function showLoading(text) {
    loadingText.textContent = text;
    loadingOverlay.style.display = 'flex';
  }
  function hideLoading() {
    loadingOverlay.style.display = 'none';
  }

  // ───────── 결과 화면 ─────────
  function showResult({ type, title, message, details, retry }) {
    Camera.stop();
    FaceAuth.stopLiveDetection();

    const icon = document.getElementById('result-icon');
    icon.className = `result-icon ${type}`;
    icon.textContent = type === 'success' ? '✓' : type === 'error' ? '✗' : 'ℹ';

    document.getElementById('result-title').textContent = title;
    document.getElementById('result-message').textContent = message;

    const detailEl = document.getElementById('result-details');
    if (details) {
      detailEl.innerHTML = details;
      detailEl.classList.add('visible');
    } else {
      detailEl.classList.remove('visible');
    }

    const retryBtn = document.getElementById('btn-result-retry');
    if (retry) {
      retryBtn.style.display = 'flex';
      retryBtn.onclick = retry;
    } else {
      retryBtn.style.display = 'none';
    }

    showScreen('result');
  }

  // ───────── AI 모델 로드 ─────────
  async function ensureModels() {
    if (modelsReady) return;
    showLoading('AI 얼굴 인식 모델 로딩 중...');
    try {
      await FaceAuth.loadModels(text => { loadingText.textContent = text; });
      modelsReady = true;
    } finally {
      hideLoading();
    }
  }

  // ───────── 카메라 권한 처리 ─────────
  async function handleGrantPermission() {
    const errEl = document.getElementById('permission-error');
    errEl.textContent = '';

    try {
      await Camera.requestPermission();
      // 모델도 미리 로드
      await ensureModels();

      if (pendingAction === 'register') {
        startRegister();
      } else {
        startAuth();
      }
    } catch (err) {
      if (err.message === 'PERMISSION_DENIED') {
        errEl.textContent = '카메라 권한이 거부되었습니다. 브라우저 설정에서 권한을 허용해주세요.';
      } else {
        errEl.textContent = err.message || '오류가 발생했습니다.';
      }
    }
  }

  // ───────── 권한 확인 후 화면 이동 ─────────
  async function goToCamera(action) {
    pendingAction = action;

    // 이미 카메라 스트림이 있고 모델도 로드됐으면 바로
    if (Camera.hasStream() && modelsReady) {
      if (action === 'register') startRegister();
      else startAuth();
      return;
    }

    // 권한 상태 확인
    if (navigator.permissions?.query) {
      try {
        const status = await navigator.permissions.query({ name: 'camera' });
        if (status.state === 'granted') {
          await ensureModels();
          if (action === 'register') startRegister();
          else startAuth();
          return;
        }
      } catch (_) {}
    }

    // 권한 요청 화면으로
    showScreen('permission');
  }

  // ───────── 얼굴 등록 시작 ─────────
  async function startRegister() {
    showScreen('register');

    const video = document.getElementById('video-register');
    const canvas = document.getElementById('canvas-register');
    const captureBtn = document.getElementById('btn-capture-register');
    const hintEl = document.getElementById('register-hint');
    const oval = document.querySelector('#screen-register .face-oval');
    const statusDot = document.querySelector('#screen-register .status-dot');
    const statusText = document.getElementById('register-status-text');

    const steps = {
      position: document.getElementById('step-position'),
      detect: document.getElementById('step-detect'),
      capture: document.getElementById('step-capture'),
    };

    // 단계 초기화
    Object.values(steps).forEach(s => s.className = 'step');
    steps.position.classList.add('active');

    captureBtn.disabled = true;
    captureBtn.classList.remove('ready');
    oval.className = 'face-oval';

    try {
      await Camera.attachToVideo(video);
    } catch (err) {
      showScreen('permission');
      return;
    }

    // 실시간 얼굴 감지 프리뷰
    let faceDetected = false;
    FaceAuth.startLiveDetection(video, canvas, (detection) => {
      if (detection) {
        if (!faceDetected) {
          faceDetected = true;
          oval.className = 'face-oval detected';
          statusDot.className = 'status-dot detected';
          statusText.textContent = '얼굴 감지됨! 캡처 버튼을 누르세요';
          captureBtn.disabled = false;
          captureBtn.classList.add('ready');
          hintEl.textContent = '얼굴이 감지되었습니다. 버튼을 눌러 등록하세요';
          steps.position.classList.remove('active');
          steps.position.classList.add('done');
          steps.detect.classList.add('active');
        }
      } else {
        if (faceDetected) {
          faceDetected = false;
          oval.className = 'face-oval';
          statusDot.className = 'status-dot scanning';
          statusText.textContent = '얼굴을 타원 안에 위치시키세요';
          captureBtn.disabled = true;
          captureBtn.classList.remove('ready');
          hintEl.textContent = '얼굴을 타원 안에 맞추세요';
          steps.detect.classList.remove('active');
          steps.position.classList.remove('done');
          steps.position.classList.add('active');
        } else {
          statusDot.className = 'status-dot scanning';
        }
      }
    });

    captureBtn.onclick = async () => {
      FaceAuth.stopLiveDetection();
      captureBtn.disabled = true;
      hintEl.textContent = '얼굴 데이터 분석 중...';
      steps.detect.classList.remove('active');
      steps.detect.classList.add('done');
      steps.capture.classList.add('active');

      try {
        await FaceAuth.register(video, canvas, ({ state, text }) => {
          statusDot.className = `status-dot ${state}`;
          statusText.textContent = text;
          oval.className = `face-oval ${state === 'success' ? 'success' : state === 'scanning' ? '' : 'detected'}`;
          hintEl.textContent = text;
        });

        steps.capture.classList.remove('active');
        steps.capture.classList.add('done');

        Camera.stop();
        showResult({
          type: 'success',
          title: '등록 완료!',
          message: '얼굴이 성공적으로 등록되었습니다.\n이제 페이스 인증으로 로그인할 수 있습니다.',
          details: `<strong>등록 시간:</strong> ${new Date().toLocaleString('ko-KR')}`,
        });
        updateRegisteredStatus();

      } catch (err) {
        Camera.stop();
        showResult({
          type: 'error',
          title: '등록 실패',
          message: err.message,
          retry: () => goToCamera('register'),
        });
      }
    };
  }

  // ───────── 얼굴 인증 시작 ─────────
  async function startAuth() {
    showScreen('auth');

    const video = document.getElementById('video-auth');
    const canvas = document.getElementById('canvas-auth');
    const authBtn = document.getElementById('btn-authenticate');
    const hintEl = document.getElementById('auth-hint');
    const oval = document.getElementById('auth-face-oval');
    const statusDot = document.querySelector('#screen-auth .status-dot');
    const statusText = document.getElementById('auth-status-text');
    const progressFill = document.getElementById('auth-progress-fill');
    const progressText = document.getElementById('auth-progress-text');

    authBtn.disabled = true;
    authBtn.classList.remove('ready');
    oval.className = 'face-oval';
    progressFill.style.width = '0%';
    progressText.textContent = '얼굴을 인식하는 중...';

    try {
      await Camera.attachToVideo(video);
    } catch (err) {
      showScreen('permission');
      return;
    }

    // 실시간 프리뷰
    let faceDetected = false;
    FaceAuth.startLiveDetection(video, canvas, (detection) => {
      if (detection) {
        if (!faceDetected) {
          faceDetected = true;
          oval.className = 'face-oval detected';
          statusDot.className = 'status-dot detected';
          statusText.textContent = '얼굴 감지됨! 인증 버튼을 누르세요';
          authBtn.disabled = false;
          authBtn.classList.add('ready');
          hintEl.textContent = '얼굴이 감지됐습니다. 인증 버튼을 누르세요';
        }
      } else {
        if (faceDetected) {
          faceDetected = false;
          oval.className = 'face-oval';
          statusDot.className = 'status-dot scanning';
          statusText.textContent = '얼굴을 타원 안에 위치시키세요';
          authBtn.disabled = true;
          authBtn.classList.remove('ready');
          hintEl.textContent = '얼굴을 타원 안에 맞추세요';
        }
      }
    });

    authBtn.onclick = async () => {
      FaceAuth.stopLiveDetection();
      authBtn.disabled = true;
      hintEl.textContent = '얼굴 대조 중...';

      try {
        const result = await FaceAuth.authenticate(
          video, canvas,
          ({ state, text }) => {
            statusDot.className = `status-dot ${state}`;
            statusText.textContent = text;
            oval.className = `face-oval ${state}`;
            hintEl.textContent = text;
          },
          (pct) => {
            progressFill.style.width = `${pct}%`;
            progressText.textContent = pct < 100 ? `분석 중... ${pct}%` : '분석 완료';
          }
        );

        Camera.stop();

        if (result.success) {
          showResult({
            type: 'success',
            title: '인증 성공!',
            message: 'StudyFactory에 오신 것을 환영합니다!',
            details: `
              <strong>인증 시간:</strong> ${new Date().toLocaleString('ko-KR')}<br>
              <strong>얼굴 유사도:</strong> ${result.similarity}%<br>
              <strong>인증 방식:</strong> 얼굴 인식 (Face ID)
            `,
          });
        } else {
          showResult({
            type: 'error',
            title: '인증 실패',
            message: `얼굴이 일치하지 않습니다.\n유사도: ${result.similarity}%`,
            retry: () => goToCamera('auth'),
          });
        }

      } catch (err) {
        Camera.stop();
        if (err.message === 'NO_REGISTERED_FACE') {
          showResult({
            type: 'info',
            title: '등록된 얼굴 없음',
            message: '먼저 얼굴을 등록해주세요.',
            retry: () => goToCamera('register'),
          });
        } else {
          showResult({
            type: 'error',
            title: '인증 오류',
            message: err.message,
            retry: () => goToCamera('auth'),
          });
        }
      }
    };
  }

  // ───────── 등록 상태 표시 ─────────
  function updateRegisteredStatus() {
    const el = document.getElementById('registered-status');
    if (FaceAuth.isRegistered()) {
      const saved = FaceAuth.getSavedFace();
      const date = new Date(saved.registeredAt).toLocaleDateString('ko-KR');
      el.textContent = `✓ 얼굴 등록됨 (${date})`;
    } else {
      el.textContent = '아직 얼굴이 등록되지 않았습니다';
    }
  }

  // ───────── 이벤트 바인딩 ─────────
  document.getElementById('btn-register').onclick = () => goToCamera('register');
  document.getElementById('btn-login').onclick = () => {
    if (!FaceAuth.isRegistered()) {
      const el = document.getElementById('registered-status');
      el.style.color = 'var(--error)';
      el.textContent = '먼저 얼굴을 등록해주세요!';
      setTimeout(() => {
        el.style.color = '';
        updateRegisteredStatus();
      }, 2500);
      return;
    }
    goToCamera('auth');
  };

  document.getElementById('btn-grant-permission').onclick = handleGrantPermission;

  document.getElementById('btn-back-permission').onclick = () => {
    document.getElementById('permission-error').textContent = '';
    showScreen('splash');
  };

  document.getElementById('btn-back-register').onclick = () => {
    FaceAuth.stopLiveDetection();
    Camera.stop();
    showScreen('splash');
  };

  document.getElementById('btn-back-auth').onclick = () => {
    FaceAuth.stopLiveDetection();
    Camera.stop();
    showScreen('splash');
  };

  document.getElementById('btn-result-home').onclick = () => {
    showScreen('splash');
    updateRegisteredStatus();
  };

  // ───────── 초기화 ─────────
  updateRegisteredStatus();
})();

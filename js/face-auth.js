/**
 * face-auth.js — face-api.js 기반 얼굴 등록 및 인증 로직
 */
const FaceAuth = (() => {
  const MODEL_URL = 'https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model';
  const STORAGE_KEY = 'studyfactory_face_data';
  const MATCH_THRESHOLD = 0.45; // 낮을수록 엄격

  let modelsLoaded = false;
  let detectionInterval = null;

  // ───────── 모델 로드 ─────────
  async function loadModels(onProgress) {
    if (modelsLoaded) return;
    onProgress?.('얼굴 감지 모델 로딩 중...');
    await Promise.all([
      faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
      faceapi.nets.faceLandmark68TinyNet.loadFromUri(MODEL_URL),
      faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL),
    ]);
    modelsLoaded = true;
    onProgress?.('모델 로딩 완료');
  }

  // ───────── 얼굴 감지 옵션 ─────────
  function getDetectorOptions() {
    return new faceapi.TinyFaceDetectorOptions({ inputSize: 224, scoreThreshold: 0.5 });
  }

  // ───────── 단일 프레임 감지 ─────────
  async function detectFace(video) {
    const detection = await faceapi
      .detectSingleFace(video, getDetectorOptions())
      .withFaceLandmarks(true)
      .withFaceDescriptor();
    return detection || null;
  }

  // ───────── 캔버스에 오버레이 그리기 ─────────
  function drawOverlay(canvas, video, detection) {
    const dims = { width: video.videoWidth, height: video.videoHeight };
    faceapi.matchDimensions(canvas, dims);
    canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);
    if (!detection) return;

    const resized = faceapi.resizeResults(detection, dims);
    // 랜드마크만 부드럽게 표시
    const ctx = canvas.getContext('2d');
    ctx.strokeStyle = 'rgba(108,99,255,0.7)';
    ctx.lineWidth = 1.5;
    const pts = resized.landmarks.positions;
    pts.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, 1.5, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(108,99,255,0.9)';
      ctx.fill();
    });
  }

  // ───────── 얼굴 등록 ─────────
  async function register(video, canvas, onStatus) {
    onStatus({ state: 'scanning', text: '얼굴을 타원 안에 위치시키세요' });

    // 3회 연속 감지 확인 (안정성)
    let stableCount = 0;
    let lastDescriptor = null;

    for (let attempt = 0; attempt < 40; attempt++) {
      await sleep(200);
      const detection = await detectFace(video);
      drawOverlay(canvas, video, detection);

      if (!detection) {
        stableCount = 0;
        onStatus({ state: 'scanning', text: '얼굴을 찾는 중...' });
        continue;
      }

      const { box } = detection.detection;
      if (!isFaceCentered(box, video)) {
        stableCount = 0;
        onStatus({ state: 'detected', text: '얼굴을 화면 중앙에 맞추세요' });
        continue;
      }

      stableCount++;
      lastDescriptor = detection.descriptor;
      onStatus({ state: 'detected', text: `안정적인 위치 확인 중... (${stableCount}/3)` });

      if (stableCount >= 3) break;
    }

    if (stableCount < 3 || !lastDescriptor) {
      throw new Error('얼굴 감지에 실패했습니다. 밝은 곳에서 다시 시도하세요.');
    }

    // 저장
    const data = {
      descriptor: Array.from(lastDescriptor),
      registeredAt: new Date().toISOString(),
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    onStatus({ state: 'success', text: '얼굴 등록 완료!' });
    return true;
  }

  // ───────── 얼굴 인증 ─────────
  async function authenticate(video, canvas, onStatus, onProgress) {
    const saved = getSavedFace();
    if (!saved) throw new Error('NO_REGISTERED_FACE');

    const savedDescriptor = new Float32Array(saved.descriptor);
    onStatus({ state: 'scanning', text: '얼굴을 타원 안에 위치시키세요' });
    onProgress(0);

    let bestDistance = Infinity;
    const maxAttempts = 30;

    for (let i = 0; i < maxAttempts; i++) {
      await sleep(200);
      const detection = await detectFace(video);
      drawOverlay(canvas, video, detection);

      const progress = Math.round((i / maxAttempts) * 100);
      onProgress(progress);

      if (!detection) {
        onStatus({ state: 'scanning', text: '얼굴을 찾는 중...' });
        continue;
      }

      if (!isFaceCentered(detection.detection.box, video)) {
        onStatus({ state: 'detected', text: '얼굴을 화면 중앙에 맞추세요' });
        continue;
      }

      const distance = faceapi.euclideanDistance(detection.descriptor, savedDescriptor);
      if (distance < bestDistance) bestDistance = distance;

      onStatus({
        state: distance < MATCH_THRESHOLD ? 'success' : 'detected',
        text: distance < MATCH_THRESHOLD
          ? `인증 성공! (유사도: ${((1 - distance) * 100).toFixed(0)}%)`
          : '얼굴 비교 중...',
      });

      if (distance < MATCH_THRESHOLD) {
        onProgress(100);
        return {
          success: true,
          similarity: ((1 - distance) * 100).toFixed(1),
          distance: distance.toFixed(4),
        };
      }
    }

    onProgress(100);
    return {
      success: false,
      similarity: ((1 - bestDistance) * 100).toFixed(1),
      distance: bestDistance.toFixed(4),
    };
  }

  // ───────── 실시간 감지 루프 (프리뷰용) ─────────
  function startLiveDetection(video, canvas, onDetect) {
    stopLiveDetection();
    let running = true;

    async function loop() {
      if (!running) return;
      const detection = await detectFace(video).catch(() => null);
      drawOverlay(canvas, video, detection);
      onDetect?.(detection);
      if (running) requestAnimationFrame(loop);
    }

    loop();
    detectionInterval = () => { running = false; };
  }

  function stopLiveDetection() {
    if (detectionInterval) {
      detectionInterval();
      detectionInterval = null;
    }
  }

  // ───────── 헬퍼 ─────────
  function isFaceCentered(box, video) {
    const vw = video.videoWidth, vh = video.videoHeight;
    const cx = box.x + box.width / 2;
    const cy = box.y + box.height / 2;
    // 화면 중앙 30% 범위 안에 있는지
    return (
      cx > vw * 0.3 && cx < vw * 0.7 &&
      cy > vh * 0.25 && cy < vh * 0.75 &&
      box.width > vw * 0.15
    );
  }

  function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

  function getSavedFace() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch { return null; }
  }

  function clearSavedFace() {
    localStorage.removeItem(STORAGE_KEY);
  }

  function isRegistered() {
    return getSavedFace() !== null;
  }

  return {
    loadModels,
    register,
    authenticate,
    startLiveDetection,
    stopLiveDetection,
    getSavedFace,
    clearSavedFace,
    isRegistered,
  };
})();

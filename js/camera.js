/**
 * camera.js — 카메라 스트림 및 권한 관리
 */
const Camera = (() => {
  let stream = null;

  const CONSTRAINTS = {
    video: {
      facingMode: 'user',
      width: { ideal: 640 },
      height: { ideal: 480 },
      frameRate: { ideal: 30 },
    },
    audio: false,
  };

  async function requestPermission() {
    if (!navigator.mediaDevices?.getUserMedia) {
      throw new Error('이 브라우저는 카메라를 지원하지 않습니다.');
    }

    // 이미 권한 허용 상태면 바로 확인
    if (navigator.permissions?.query) {
      try {
        const status = await navigator.permissions.query({ name: 'camera' });
        if (status.state === 'denied') {
          throw new Error('PERMISSION_DENIED');
        }
      } catch (e) {
        if (e.message === 'PERMISSION_DENIED') throw e;
        // permissions API 미지원은 무시하고 계속
      }
    }

    try {
      stream = await navigator.mediaDevices.getUserMedia(CONSTRAINTS);
      return stream;
    } catch (err) {
      if (err.name === 'NotAllowedError' || err.name === 'PermissionDeniedError') {
        throw new Error('PERMISSION_DENIED');
      } else if (err.name === 'NotFoundError') {
        throw new Error('카메라를 찾을 수 없습니다.');
      } else if (err.name === 'NotReadableError') {
        throw new Error('카메라가 이미 사용 중입니다.');
      }
      throw new Error('카메라 접근에 실패했습니다.');
    }
  }

  async function attachToVideo(videoEl) {
    if (!stream) {
      stream = await requestPermission();
    }
    videoEl.srcObject = stream;
    return new Promise((resolve, reject) => {
      videoEl.onloadedmetadata = () => {
        videoEl.play().then(resolve).catch(reject);
      };
      videoEl.onerror = reject;
    });
  }

  function stop() {
    if (stream) {
      stream.getTracks().forEach(t => t.stop());
      stream = null;
    }
  }

  function hasStream() {
    return stream !== null && stream.active;
  }

  return { requestPermission, attachToVideo, stop, hasStream };
})();

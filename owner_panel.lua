<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Str1ker Owner · Presets</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background: radial-gradient(ellipse at top, #0d1a2e 0%, #050810 70%);
    min-height: 100vh; display: flex; align-items: center; justify-content: center;
    padding: 20px; color: #e5eaf3; overflow: hidden;
  }
  body::before {
    content: ''; position: fixed; inset: 0;
    background: radial-gradient(circle at 50% 0%, rgba(59,130,246,0.15), transparent 60%);
    pointer-events: none;
  }
  .panel {
    width: 100%; max-width: 480px;
    background: linear-gradient(180deg, #0b1220 0%, #08101c 100%);
    border-radius: 14px; border: 1px solid #1c2a44;
    overflow: hidden; position: relative;
    box-shadow: 0 0 0 1px rgba(59,130,246,0.08), 0 30px 80px rgba(0,0,0,0.7), 0 0 60px rgba(59,130,246,0.15);
    animation: entry 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
  }
  @keyframes entry { from { opacity:0; transform: scale(0.9) translateY(20px); } to { opacity:1; transform: scale(1) translateY(0); } }
  .panel::after {
    content: ''; position: absolute; top: 0; left: 0; right: 0; height: 1px;
    background: linear-gradient(90deg, transparent, #3B82F6, transparent); opacity: 0.6;
  }
  .header {
    display: flex; align-items: center; gap: 12px; padding: 16px 18px;
    background: linear-gradient(180deg, #0a1424 0%, #0d1a30 100%);
    border-bottom: 1px solid #1c2a44; position: relative;
  }
  .logo-wrap { position: relative; width: 40px; height: 40px; }
  .logo-wrap::before {
    content: ''; position: absolute; inset: -4px;
    background: radial-gradient(circle, rgba(59,130,246,0.5), transparent 70%);
    border-radius: 14px; animation: glowPulse 2.5s ease-in-out infinite;
  }
  @keyframes glowPulse { 0%,100% { opacity:0.6; transform:scale(1); } 50% { opacity:1; transform:scale(1.15); } }
  .logo {
    position: relative; width: 40px; height: 40px;
    background: linear-gradient(135deg, #3B82F6, #1E40AF);
    border-radius: 10px; display: flex; align-items: center; justify-content: center;
    font-weight: 800; font-size: 20px; color: white;
    box-shadow: 0 4px 16px rgba(59,130,246,0.4), inset 0 1px 0 rgba(255,255,255,0.2);
  }
  .header-text { flex: 1; }
  .header-text h1 { font-size: 14px; font-weight: 700; color: #e5eaf3; letter-spacing: 0.3px; }
  .header-text p { font-size: 10px; color: #6b7a99; margin-top: 3px; letter-spacing: 0.5px; }
  .badge {
    display: inline-flex; align-items: center; gap: 6px; padding: 5px 10px;
    background: rgba(16,185,129,0.08); border: 1px solid rgba(16,185,129,0.3);
    border-radius: 12px; font-size: 9px; font-weight: 700; letter-spacing: 1px; color: #10B981;
  }
  .dot {
    width: 6px; height: 6px; border-radius: 50%; background: #10B981;
    box-shadow: 0 0 0 0 rgba(16,185,129,0.7); animation: pulseDot 1.8s infinite;
  }
  @keyframes pulseDot {
    0%   { box-shadow: 0 0 0 0 rgba(16,185,129,0.7); }
    70%  { box-shadow: 0 0 0 6px rgba(16,185,129,0); }
    100% { box-shadow: 0 0 0 0 rgba(16,185,129,0); }
  }
  .close-btn {
    width: 26px; height: 26px; border-radius: 7px;
    background: rgba(239,68,68,0.08); border: 1px solid rgba(239,68,68,0.2);
    color: #EF4444; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s;
  }
  .close-btn:hover { background: rgba(239,68,68,0.15); transform: rotate(90deg); }
  .tabs { display: flex; background: #0a1424; border-bottom: 1px solid #1c2a44; position: relative; }
  .tab {
    flex: 1; padding: 13px 12px; background: transparent; border: none;
    color: #6b7a99; font-size: 12px; font-weight: 600; cursor: pointer;
    transition: color 0.2s; letter-spacing: 0.3px;
  }
  .tab.active { color: #3B82F6; }
  .tab-indicator {
    position: absolute; bottom: -1px; left: 0; width: 50%; height: 2px;
    background: #3B82F6; box-shadow: 0 0 12px #3B82F6, 0 0 4px #3B82F6;
    transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  }
  .content { padding: 18px; }
  .label {
    font-size: 10px; color: #6b7a99; font-weight: 700;
    letter-spacing: 1.2px; text-transform: uppercase; margin-bottom: 10px;
  }
  .presets {
    display: grid; grid-template-columns: repeat(4, 1fr);
    gap: 8px; margin-bottom: 14px;
  }
  .preset {
    position: relative; padding: 14px 6px 12px;
    background: #16233B; border: 1px solid #1c2a44;
    border-radius: 9px; color: #e5eaf3;
    font-size: 12px; font-weight: 700; letter-spacing: 0.3px;
    cursor: pointer; transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    overflow: hidden;
  }
  .preset span.small {
    display: block; font-size: 9px; color: #6b7a99;
    margin-top: 3px; font-weight: 500; letter-spacing: 0;
  }
  .preset::before {
    content: ''; position: absolute; inset: 0;
    background: radial-gradient(circle at center, rgba(59,130,246,0.3), transparent 70%);
    opacity: 0; transition: opacity 0.3s;
  }
  .preset:hover {
    border-color: #3B82F6; transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(59,130,246,0.25);
  }
  .preset:hover::before { opacity: 1; }
  .preset.active {
    background: linear-gradient(135deg, #2563EB, #1E40AF);
    border-color: #60A5FA;
    color: white;
    box-shadow: 0 6px 24px rgba(59,130,246,0.55), inset 0 1px 0 rgba(255,255,255,0.25);
    transform: translateY(-2px) scale(1.02);
  }
  .preset.active span.small { color: rgba(255,255,255,0.7); }
  .preset.custom { grid-column: span 2; }
  .preset.custom span.small { color: #3B82F6; }
  .preset.custom.active span.small { color: rgba(255,255,255,0.8); }
  .custom-box {
    overflow: hidden; max-height: 0; opacity: 0;
    transition: max-height 0.35s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.25s, margin-bottom 0.3s;
    margin-bottom: 0;
  }
  .custom-box.show {
    max-height: 80px; opacity: 1; margin-bottom: 14px;
  }
  .custom-row {
    display: flex; gap: 8px;
  }
  .field {
    flex: 1; background: #16233B; border: 1px solid #1c2a44;
    border-radius: 7px; padding: 11px 12px; color: #e5eaf3;
    font-size: 13px; font-weight: 600; font-family: inherit;
    outline: none; transition: all 0.2s;
  }
  .field:focus { border-color: #3B82F6; box-shadow: 0 0 0 3px rgba(59,130,246,0.15); }
  .dropdown {
    flex: 1.4; background: #16233B; border: 1px solid #1c2a44;
    border-radius: 7px; padding: 11px 12px; color: #e5eaf3;
    font-size: 13px; font-weight: 600; cursor: pointer;
    display: flex; justify-content: space-between; align-items: center; transition: all 0.2s;
  }
  .dropdown:hover { border-color: #3B82F6; }
  .qty-row { display: flex; gap: 8px; margin-bottom: 14px; }
  .btn {
    position: relative; width: 100%; padding: 13px;
    background: linear-gradient(135deg, #2563EB 0%, #1E40AF 100%);
    border: 1px solid #3B82F6; border-radius: 9px; color: white;
    font-size: 13px; font-weight: 700; letter-spacing: 0.8px;
    cursor: pointer; transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    overflow: hidden;
    box-shadow: 0 4px 16px rgba(59,130,246,0.35), inset 0 1px 0 rgba(255,255,255,0.15);
  }
  .btn::before {
    content: ''; position: absolute; top: 0; left: -100%; width: 100%; height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.35), transparent);
    transition: left 0.7s cubic-bezier(0.4, 0, 0.2, 1);
  }
  .btn:hover::before { left: 100%; }
  .btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 8px 24px rgba(59,130,246,0.55), inset 0 1px 0 rgba(255,255,255,0.2);
  }
  .btn:active { transform: translateY(0) scale(0.99); }
  .result {
    background: linear-gradient(180deg, #0a1424 0%, #08111f 100%);
    border: 1px solid #1c2a44; border-radius: 9px;
    padding: 10px; margin-top: 12px; min-height: 70px;
    max-height: 240px; overflow-y: auto; position: relative;
  }
  .result::-webkit-scrollbar { width: 4px; }
  .result::-webkit-scrollbar-thumb { background: #3B82F6; border-radius: 2px; }
  .key-row {
    background: linear-gradient(135deg, #16233B 0%, #142a4a 100%);
    border: 1px solid #1f3255; border-radius: 7px;
    padding: 11px 12px; margin-bottom: 7px;
    display: flex; justify-content: space-between; align-items: center; gap: 10px;
    opacity: 0; transform: translateY(8px);
    animation: keyIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    position: relative; overflow: hidden; transition: all 0.2s;
  }
  .key-row::after {
    content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 2px;
    background: linear-gradient(180deg, #3B82F6, #06B6D4);
  }
  @keyframes keyIn { to { opacity: 1; transform: translateY(0); } }
  .key-row:nth-child(1) { animation-delay: 0.05s; }
  .key-row:nth-child(2) { animation-delay: 0.10s; }
  .key-row:nth-child(3) { animation-delay: 0.15s; }
  .key-row:nth-child(4) { animation-delay: 0.20s; }
  .key-text {
    font-family: ui-monospace, "Courier New", monospace;
    font-size: 12px; color: #06B6D4; font-weight: 700;
    letter-spacing: 0.5px; flex: 1;
    overflow: hidden; text-overflow: ellipsis;
    text-shadow: 0 0 8px rgba(6,182,212,0.4);
  }
  .key-meta { font-size: 10px; color: #6b7a99; margin-top: 3px; }
  .copy-btn {
    background: rgba(59,130,246,0.1); border: 1px solid #1E40AF;
    color: #3B82F6; padding: 7px 12px; border-radius: 6px;
    font-size: 10px; font-weight: 700; cursor: pointer; white-space: nowrap;
    transition: all 0.2s;
  }
  .copy-btn:hover { background: rgba(59,130,246,0.2); box-shadow: 0 0 12px rgba(59,130,246,0.35); }
  .status {
    display: flex; align-items: center; gap: 8px;
    font-size: 11px; color: #10B981; margin-top: 12px;
  }
  .status-dot {
    width: 6px; height: 6px; border-radius: 50%;
    background: currentColor; box-shadow: 0 0 6px currentColor;
  }
</style>
</head>
<body>
  <div class="panel">
    <div class="header">
      <div class="logo-wrap"><div class="logo">S</div></div>
      <div class="header-text">
        <h1>Str1ker · Owner</h1>
        <p>PAINEL ADMINISTRATIVO</p>
      </div>
      <div class="badge"><span class="dot"></span>PROTECTED</div>
      <button class="close-btn">×</button>
    </div>

    <div class="tabs">
      <button class="tab active">Gerar Keys</button>
      <button class="tab">Listar Keys</button>
      <div class="tab-indicator"></div>
    </div>

    <div class="content">
      <div class="label">Duração</div>
      <div class="presets">
        <div class="preset">1h<span class="small">hora</span></div>
        <div class="preset">12h<span class="small">meio dia</span></div>
        <div class="preset active">1d<span class="small">dia</span></div>
        <div class="preset">3d<span class="small">3 dias</span></div>
        <div class="preset">7d<span class="small">semana</span></div>
        <div class="preset">30d<span class="small">mês</span></div>
        <div class="preset custom">Custom<span class="small">definir manualmente</span></div>
      </div>

      <div class="custom-box">
        <div class="custom-row">
          <input class="field" type="number" value="5" placeholder="Qtd">
          <div class="dropdown"><span>Dias</span><span>▾</span></div>
        </div>
      </div>

      <div class="label">Quantidade</div>
      <div class="qty-row">
        <input class="field" type="number" value="1" placeholder="Nº de keys">
      </div>

      <button class="btn">GERAR KEYS</button>

      <div class="result">
        <div class="key-row">
          <div style="flex:1">
            <div class="key-text">STR1KER-A3F2-9K2M-B7X4-Q1P8</div>
            <div class="key-meta">1 dia · 24h</div>
          </div>
          <button class="copy-btn">COPIAR</button>
        </div>
      </div>

      <div class="status">
        <span class="status-dot"></span>
        Gerada 1 key · 1 dia
      </div>
    </div>
  </div>

  <script>
    document.querySelectorAll('.preset').forEach(p => {
      p.addEventListener('click', () => {
        document.querySelectorAll('.preset').forEach(x => x.classList.remove('active'));
        p.classList.add('active');
        document.querySelector('.custom-box').classList.toggle('show', p.classList.contains('custom'));
      });
    });
  </script>
</body>
</html>

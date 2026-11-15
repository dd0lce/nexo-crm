<?php
require __DIR__ . '/includes/layout.php';
$u = layout_inicio('dashboard');
$h = (int) date('G');
$saludo = $h < 12 ? 'Buenos días' : ($h < 19 ? 'Buenas tardes' : 'Buenas noches');
// ponytail: cifras de muestra del prototipo; conectar a consultas reales en el Entregable 3
?>
      <div class="encabezado">
        <div class="titulos">
          <h1 class="h1"><?= e("$saludo, {$u['nombre']}") ?></h1>
          <p>Resumen comercial · Octubre 2026</p>
        </div>
        <div class="botones">
          <button class="btn btn-secundario" type="button">Exportar</button>
          <a class="btn btn-primario" href="oportunidades.php"><?= icono('mas', 13.3333, 13.3333) ?> Nueva oportunidad</a>
        </div>
      </div>

      <section class="kpis">
        <div class="tarjeta kpi"><span>Contactos activos</span><strong>1.284</strong><small class="sube">+8,2% vs. mes anterior</small></div>
        <div class="tarjeta kpi"><span>Oportunidades abiertas</span><strong>86</strong><small class="sube">+4 esta semana</small></div>
        <div class="tarjeta kpi"><span>Ingresos del mes</span><strong>$412.500</strong><small class="sube">+12,5% vs. mes anterior</small></div>
        <div class="tarjeta kpi"><span>Tasa de conversión</span><strong>24,6%</strong><small class="baja">−1,2% vs. mes anterior</small></div>
      </section>

      <section class="fila2">
        <div class="tarjeta">
          <div class="tarjeta-titulo"><h3>Embudo de ventas</h3><a href="oportunidades.php">Ver pipeline</a></div>
          <div class="barras">
            <?php foreach ([['Prospecto', 100, '32 · $180.000'], ['Calificado', 65.7, '21 · $126.400'], ['Propuesta', 56.4, '18 · $98.700'],
                            ['Negociación', 28.2, '9 · $64.200'], ['Ganado', 18.9, '6 · $41.000']] as [$etapa, $pct, $monto]): ?>
              <div class="barra"><span><?= $etapa ?></span>
                <div class="pista"><i class="<?= $etapa === 'Ganado' ? 'verde' : '' ?>" style="width:<?= $pct ?>%"></i></div>
                <b><?= $monto ?></b></div>
            <?php endforeach; ?>
          </div>
        </div>

        <div class="tarjeta">
          <div class="tarjeta-titulo"><h3>Próximas actividades</h3><a href="actividades.php">Ver todas</a></div>
          <div class="actividad"><span class="actividad-ic"><?= icono('telefono', 18.2406, 18.2735) ?></span>
            <div><strong>Llamada — Grupo Andino</strong><small class="tenue">Hoy · 10:30</small></div><span class="badge badge-info">Llamada</span></div>
          <div class="actividad"><span class="actividad-ic"><?= icono('correo', 18.3335, 15) ?></span>
            <div><strong>Propuesta — Textiles Sur</strong><small class="tenue">Hoy · 15:00</small></div><span class="badge badge-aviso">Pendiente</span></div>
          <div class="actividad"><span class="actividad-ic"><?= icono('actividades-gris', 16.6667, 18.3333) ?></span>
            <div><strong>Cierre — Logística MX</strong><small class="tenue">Mañana · 09:00</small></div><span class="badge badge-neutro">Reunión</span></div>
        </div>
      </section>

      <section class="tarjeta">
        <div class="tarjeta-titulo"><h3>Oportunidades recientes</h3><a href="oportunidades.php">Ver todas</a></div>
        <div class="tabla-wrap">
          <table>
            <thead><tr><th>Oportunidad</th><th>Empresa</th><th>Etapa</th><th>Valor</th><th>Responsable</th><th>Cierre estimado</th></tr></thead>
            <tbody>
              <tr><td>Renovación licencias 2027</td><td>Grupo Andino</td><td><span class="badge badge-info">Negociación</span></td><td>$48.000</td><td>Ana Torres</td><td>15 nov 2026</td></tr>
              <tr><td>Implementación módulo RR. HH.</td><td>Textiles Sur</td><td><span class="badge badge-aviso">Propuesta</span></td><td>$32.500</td><td>Luis Pérez</td><td>30 nov 2026</td></tr>
              <tr><td>Soporte anual premium</td><td>Logística MX</td><td><span class="badge badge-exito">Ganado</span></td><td>$18.900</td><td>Carla Ríos</td><td>20 oct 2026</td></tr>
            </tbody>
          </table>
        </div>
      </section>
<?php layout_fin();

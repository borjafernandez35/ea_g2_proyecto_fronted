<h1>MÍNIMO 2</h1>
<b> HAcer un buscador de eventos que filtre información georeferenciada.</b>

<h2><i>Implementaciones realizadas:</i></h2>
<ul>
  <li>Añadida la visualización de la ubicación en la lista de actividades.</li>
  <li>Añadido campo en el formulario de creación de nueva actividad para obtener la localización. Según haces click encima de ese campo, el dispositivo obtiene tus coordenadas.</li>
  <li>Añadida funcionalidad para que coger la ubicación del usuario según inicia sesión.</li>
</ul>

<h2><i>Errores detectados:</i></h2>
<ul>
  <li>La localización la coge correctamente y se visualiza, pero a la hora de enviar estos datos al backend, no lo hace correctamente y no se almacenan los datos en Mongo.</li>
  <li>Debido al error anterior, la localización no se muestra correctamente en el listado, apareciendo "Unknown"</li>
</ul>


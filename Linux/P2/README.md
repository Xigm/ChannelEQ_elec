# Práctica 1

Manejo del editor TerosHDL.

## Contenidos

[TOC]

# Objetivos

El objetivo técnico de esta práctica es realizar una toma de contacto con el editor TerosHDL y aprender a lanzar algunas simulaciones utilizando el programa.

Con esto se pretenden alcanzar los siguientes objetivos formativos:

- Realizar una primera toma de contacto con el editor TerosHDL
- Realizar el diseño en VHDL de un bloque sencillo utilizando el editor
- Realizar el diseño en VHDL de un testbench para el bloque desarrollado, utilizando el generador de plantillas del editor y realizando modificaciones sobre el código generado
- Utilizar Teros para compilar el código y ejecutar la simulación, así como lanzar el visor de ondas
- Aprender a utilizar el visor de formas de onda ``GTKwave`` para depurar los diseños
- Alcanzar un nivel de manejo con la herramienta que permita desarrollar conceptos más avanzados en las siguientes prácticas

# Trabajo previo

El alumno debe asegurarse de que ha seguido las instrucciones en [Instalación de las herramientas](https://gitlab.com/edcmit/edc-practicas#instalaci%C3%B3n-de-las-herramientas), así como las instrucciones en [Instalación de TerosHDL](https://gitlab.com/edcmit/edc-practicas#instalaci%C3%B3n-de-teroshdl)

Es recomendable comprobar que las herramientas están instaladas y se encuentran en el ``$PATH``:

    source ~/fosshdl/env.rc
    ghdl --version
    gtkwave --version
    yosys --version

El alumno debería haber repasado el VHDL básico, para síntesis y simulación. Asimismo, debería haber repasado los diseños de la [práctica 0](practica0)

# Toma de contacto con TerosHDL

## Primeros pasos

Antes de arrancar TerosHDL, debemos cargar las variables de entorno en un terminal:

    source ~/fosshdl/env.rc

Desde ese terminal, lanzamos Visual Studio Code. De esta forma, las herramientas libres para trabajar con VHDL estarán en nuestro ``$PATH`` y el editor las encontrará sin problemas:

    code

Una vez abierto Visual Studio Code, hacemos click en el botón 'TerosHDL' que aparece en la barra de la izquierda:

![Botón TerosHDL](practica1/img/TerosHDLbutton.png "Botón TerosHDL")

### Configuración

La configuración de TerosHDL está en el botón de la rueda dentada:

![Configuración de TerosHDL](practica1/img/TerosHDLconfiguration.png "Configuración TerosHDL")

Por ahora dejaremos la configuración por defecto, salvo en el visor de ondas ('General' -> 'Select the waveform viewer'), en el que cambiaremos ``VCDrom`` por ``GTKwave``.

### Crear un proyecto

Para crear un nuevo proyecto, hacemos click en el botón del signo ``+``:

![Crear proyecto](practica1/img/TerosHDLnewproject.png "Crear proyecto")

_Nota_: Utilizando este mismo botón ('Add/load project') podemos cargar proyectos ya existentes en Teros. Por defecto, Teros guarda los proyectos en ``~/.prj_config.teros``, pero si queremos guardarlos o añadirlos a un repositorio ``git`` podemos exportarlos (haciendo click en el icono del disquete, 'Export project') en formato [EDAM](https://edalize.readthedocs.io/en/latest/edam/api.html) (EDA Metadata) y luego importarlos en Teros en otro PC.

_Nota_: Una curiosidad a comentar es que el formato EDAM resulta muy interesante, ya que puede ser leído por la herramienta [Edalize](https://edalize.readthedocs.io/en/latest/), la cual ofrece un interfaz común a múltiples herramientas de simulación e implementación de HDL (como pueden ser Yosys, Xilinx Vivado, Intel Quartus, Questa Simulator, GHDL, etc...).

Al crear el proyecto, marcamos la opción 'Empty project' y damos un nombre al proyecto. Ya que vamos a hacer un contador, podemos llamar al proyecto simplemente 'contador', o 'practica1', lo que prefieran.

## Creación de un primer diseño

Vamos a crear un contador sencillo y su testbench. Para crear un fichero nuevo, tenemos que ir al menú ``File`` -> ``New File``. En el fichero que se abre, hacemos click en 'Select a language' y seleccionamos VHDL.

Ahora escribiremos el código de un contador. Se recuerda que la tecla <kbd>TAB</kbd>, es decir, el tabulador, se utiliza para el _autocompletion_, esto es, aceptar las sugerencias del texto que nos ofrece el editor, las cuales verán que facilitan y aceleran la escritura del código.

Escribiremos la sección library del contador (muy rápidamente si hacen uso del _autocompletion_), y una vez escrita la sección guardaremos el fichero. Para guardar el fichero, tendremos que seleccionar ``File`` -> ``Save`` (o pulsar <kbd>Ctrl+s</kbd>). La primera vez que guardemos el fichero nos pedirá la ruta en la que queramos guardarlo: se sugiere que guarden todos los ficheros de esta práctica en una carpeta creada para la ocasión.

Una vez que hemos guardado el fichero, ya podemos añadirlo al proyecto de Teros. Para añadir ficheros ya existentes, haremos click en el botón del signo ``+`` de nuestro proyecto:

![Añadir fichero](practica1/img/TerosHDLaddfile.png "Añadir fichero")

En este caso, elegimos la opción ``Select files from browser``, aunque las otras dos opciones también pueden ser válidas en proyectos más grandes.

Navegamos hasta la carpeta en la que tenemos nuestro fichero y lo seleccionamos. ahora deberíamos ver el fichero como parte de nuestro proyecto:

![Fichero añadido al proyecto](practica1/img/TerosHDLfilewasadded.png "Fichero añadido al proyecto")

Una vez añadido el fichero al proyecto, podemos abrirlo haciendo doble click en el fichero que aparece en el proyecto.

Describiremos la entidad de un contador sin generics, con los siguientes puertos:

| puerto | dirección | tipo de dato         | función |
| ---    | ---       | ---                  | ---     |
| clk    | in        | std_ulogic           | Reloj activo por flanco de subida |
| rst    | in        | std_ulogic           | Reset activo a nivel alto |
| ena    | in        | std_ulogic           | Señal de habilitación del contador. Activa a nivel alto |
| Q      | out       | unsigned(7 downto 0) | Valor actual de la cuenta |

Y, por supuesto, también describiremos la arquitectura del contador.

Si tenemos errores o warnings nos aparecerán estos iconos en la esquina inferior izquierda del programa:

![Errores y warnings](practica1/img/TerosHDLerrorswarnings.png "Errores y warnings")

Si hacemos click en los iconos se nos abrirá una ventana que nos señalará los problemas existentes en nuestro código. Es interesante dejar esta ventana siempre abierta, ya que en la pestaña ``OUTPUT`` nos indicará la salida de las herramientas cuando lancemos la simulación más adelante. Una vez resolvamos los problemas que pueda tener nuestro código, continuaremos al siguiente apartado.

## Creación de un testbench

Ahora crearemos un testbench para nuestro contador. Pero en lugar de repetir los pasos anteriores y crearlo desde cero, utilizaremos una de las plantillas disponibles en Teros, haciendo click en el icono del generar plantilla:

![Generar plantilla](practica1/img/TerosHDLgeneratetemplate.png "Generar plantilla")

Seleccionamos 'VHDL testbench', y veremos que en la pestaña ``OUTPUT`` se nos indica el mensaje:

    Code copied to clipboard.

Entonces, creamos un fichero nuevo (``File`` -> ``New File``), seleccionamos lenguaje VHDL y pegamos el texto que está en el portapapeles, por ejemplo haciendo <kbd>Ctrl+v</kbd>.

Ajustamos lo que que queramos cambiar en el testbench y lo guardamos.

En particular, queremos añadir un mecanismo de asfixia de reloj para que la simulación pare automáticamente. Añadiremos este código antes del begin de la arquitectura:

    -- Simulation control
    signal endsim : boolean := false;

Y modificaremos el ``clk_process`` para que deje de dar flancos de reloj si ``endsim = true``:

    clk_process : process
    begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
      if endsim=true then
        wait;
      end if;
    end process;

También debemos añadir un proceso de estímulos, y asegurarnos de que termina en una sentencia ``wait;``, ya que si no, se repetirá indefinidamente, por lo que la simulación no terminará, aunque deje de haber eventos de reloj (ya que el proceso de estímulos seguiría generando eventos):

    stim_process : process
      begin
      rst <= '1';
      ena <= '0';
      wait for 2 * clk_period;
      rst <= '0';
      ena <= '1';
      wait for 100 * clk_period;
      endsim <= true;
      wait;
    end process;

Tras esto, una vez guardado el fichero, lo añadiremos al proyecto como hicimos con el contador.

## Seleccionando el top-level del proyecto

Ahora mismo tendremos el proyecto con la siguiente jerarquía:

![Jerarquía con el contador como top-level](practica1/img/TerosHDLhierarchywrong.png "Jerarquía con el contador como top-level")

Sin embargo, querríamos que tb_contador fuera el top-level del proyecto, para que sea el top-level de nuestra simulación, ya que no queremos estimulador el contador sin entradas.

Para cambiar el top-level, es tan sencillo como marcar el 'tick' a la derecha del fichero que queramos que sea el top-level, en nuestro caso el testbench del contador:

![Poner como top-level](practica1/img/TerosHDLsetastop.png "Poner como top-level")

Y ya deberíamos ver el fichero correcto como top-level y la jerarquía correcta en la ventana 'Hierarchy View':

![Jerarquía con el testbench como top-level](practica1/img/TerosHDLhierarchyright.png "Jerarquía con el testbench como top-level")

## Simulando nuestro diseño

Podemos ejecutar todos los testbenches de nuestro diseño si hacemos click en el botón 'Start' del proyecto:

![Botón Start](practica1/img/TerosHDLstartbutton.png "Botón Start")

Si este proceso se quedara atascado y no terminara, podemos cancelarlo pulsando el botón 'Stop', que está justo al lado (el rectángulo rojo).

Ejecutar los tests de esta manera es muy útil para automatizar tests (lo cual será importante cuando tengamos muchos tests), sin embargo no nos permite ver la forma de onda de la simulación. Para ver la forma de onda, en la sección 'Runs list' del 'Project Manager' de Teros, hacemos click en 'Run with GUI':

![Ejecutar con GUI](practica1/img/TerosHDLrunwithgui.png "Ejecutar con GUI")

Al hacer click en dicho botón se abrirá ``GTKwave`` con la forma de onda generada durante la simulación. ``GTKwave`` tiene 3 áreas principales:

1. La jerarquia del diseño, arriba a la izquierda
2. Las señales y puertos disponibles en el elemento jerárquico seleccionado, abajo a la izquierda
3. El visor de formas de onda, a la derecha

Si en el área de jerarquía del diseño seleccionamos el testbench, en el área de objetos (señales y puertos) disponibles nos saldrán las señales del testbench. Podemos hacer click en el signo ``+`` a la derecha del testbench para abrir la jerarquía y ver lo que contiene (nos tiene que salir que tiene instanciado el contador). Si seleccionamos el contador podremos ver qué señales internas tiene. Podemos seleccionar varias de estas señales y, haciendo click en el botón 'Append' podemos añadirlas al visor de forma de onda. Otra forma de añadir señales es simplemente arrastrándolas hasta el área del visor de formas de onda.

![Jerarquía y señales en GTKwave](practica1/img/GTKwavemanejo1.png "Jerarquía y señales en GTKwave")

Una vez añadidas las señales a GTKwave, podemos ajustar el zoom con los botones 'Zoom Fit', 'Zoom Out' y 'Zoom In':

![Botones de zoom en GTKwave](practica1/img/GTKwavezoombuttons.png "Botones de zoom en GTKwave")

También podemos, haciendo click con el botón derecho en una señal, cambiarla de formato (hex/dec/bin/etc), de color, o insertar separadores o comentarios. También podemos seleccionar varias señales a la vez (manteniendo pulsado <kbd>Ctrl</kbd> o <kbd>Shift</kbd>) y al hacer click derecho afectaremos a todas las señales selecionadas.

En la siguiente imagen se pueden ver distintas señales en el visor de onda, algunas de ellas con diferentes formatos:

![Señales en el visor de ondas](practica1/img/GTKwavemanejo2.png "Señales en el visor de ondas")

El alumno debe comprobar que el contador funciona correctamente (tal vez quieran dar más de 100 ciclos en el testbench para comprobar el desbordamiento del contador), y arreglar cualquier fallo de funcionamiento detectado.

Una cosa importante que deben tener en cuenta es que los ficheros fuente no se guardan automáticamente cuando se lanzan las simulaciones, así que tienen que asegurarse de ir guardando su trabajo antes de lanzarlas. Cuando un fichero modificado no ha sido guardado, se indica en el editor con un punto blanco a la derecha del nombre del fichero. Por ejemplo, en la siguiente imagen, el primer fichero tiene modificaciones que no han sido guardadas, por lo que dichas modificaciones no se reflejarán en las simulaciones:

![Modificaciones sin guardar](practica1/img/TerosHDLunsavedfile.png "Modificaciones sin guardar")

Se recomienda usar, antes de lanzar las simulaciones, ``File`` -> ``Save`` o su atajo <kbd>Ctrl+s</kbd> para cada fichero modificado, o directamente ``File`` -> ``Save All`` para guardar todos los ficheros modificados.


# Trabajo no presencial

## Diseño del PRBS

Uno de los bloques que debemos crear para el estimador de canal es un el bloque ``PRBS`` (Pseudo-Random Binary Sequence), que genera los números pseudo-aleatorios que nos indicarán el signo de los pilotos del símbolo OFDM. Este diseño es, a nivel de código, relativamente parecido a un contador y podemos plantearlo basándolo en un registro interno de 11 bits.

Podríamos definir las entradas y salidas del PRBS de la siguiente manera:

| puerto | dirección | tipo de dato | función |
| ---    | ---       | ---          | ---     |
| clk    | in        | std_ulogic   | Reloj activo por flanco de subida |
| rst    | in        | std_ulogic   | Reset activo a nivel alto |
| ena    | in        | std_ulogic   | Señal de habilitación del PRBS (desplaza el registro). Activa a nivel alto |
| signo  | out       | std_ulogic   | Signo del piloto |

Para que sea más sencillo interpretar el diagrama que viene en la especificación del protocolo, tenemos la opción de definir las señales ``reg`` y ``p_reg`` como ``std_ulogic_vector(11 downto 1)`` en lugar de ``std_ulogic_vector(10 downto 0)`` ya que en el diagrama los biestables están numerados del 1 al 11 y no del 0 al 10.

Una vez que tengamos definidas esas dos señales, tendremos que hacer un proceso síncrono (que como ya saben, siempre es casi igual) y un proceso combinacional, que realice el desplazamiento de los bits (incluyendo la XOR que aparece en el diagrama) si la entrada ``ena`` (enable) del PRBS está activa, y que mantenga en ``p_reg`` el valor actual de ``reg`` si ``ena`` está inactiva. En el proceso síncrono, debemos prestar especial atención al valor de reset de ``reg``, ya que dicho valor nos condicionará la secuencia de salida, por lo que tenemos que poner el valor de reset que nos indique el estándar.

_Nota_: a la hora de hacer el desplazamiento, podemos desplazar los bits de un en uno (por ejemplo, ``p_reg(2) <= reg(1)``), pero será más cómodo si tomamos trozos enteros del vector, por ejemplo podemos desplazar varios bits una posición si hacemos ``p_reg(4 downto 2) <= reg(3 downto 1)``. Se deja al alumno el ejercicio de determinar cuántos bits debe desplazar y en qué dirección, en función de lo que indique el estándar a implementar.

Tras haber realizado el código sintetizable del PRBS, debemos realizarle un testbench sencillo y comprobar en la simulación que los primeros valores son correctos y coinciden con lo esperado. Si mantenemos ``ena`` habilitado, deberíamos leer 11 unos y a partir de ahí algunos ceros (deben ver exactamente lo mismo que en el modelo Matlab que han realizado). En futuras prácticas automatizaremos la comprobación de los (2^11)-1 valores posibles.

## Lectura de la documentación de TerosHDL

Se recomienda encarecidamente que lean la [documentación de TerosHDL](https://terostechnology.github.io/terosHDLdoc/). La documentación no es muy extensa (ya que no documenta todo VSCode, sino simplemente la extensión que estamos usando). En particular, les puede ser muy interesante el generador de documentación, el visor de máquinas de estado, y el auto-formateador de código. Se recomienda que vayan probando aquello que vayan leyendo y les sea interesante.

# Preparación para la siguiente práctica

El alumno debe realizar copia de seguridad de su trabajo. En particular, tendría sentido que repasaran o estudiaran el control de versiones utilizando ``git``. Deben crearse una cuenta en https://gitlab.com, ir a https://gitlab.com/edcmit, seleccionar el grupo correspondiente al curso académico actual, y hacer click en 'request access'. Una vez que hayan solicitado acceso al grupo, el profesor les creará un proyecto (que incluye un repositorio git) dentro del grupo para que puedan realizar en él las prácticas y el trabajo de la asignatura. Será importante que se manejen con ``git`` ya que será necesario para la práctica futura de integración contínua (y porque es una buena práctica en el desarrollo de proyectos, la cual les acomparañará de por vida ayudándoles a que nunca pierdan código desarrollado). Pueden encontrar una guía de ``git`` por línea de comandos que he preparado en el siguiente enlace: https://gitlab.com/hgpub/gitintro. Adicionalmente, VSCode también dispone de extensiones para manejar ``git``, pero es muy recomendable que entiendan primero los conceptos básicos de manejo del repositorio.

Se recomienda entonces que exporten el proyecto de Teros (haciendo click en el icono del disquete, 'Export project', en el proyecto) y añadan el fichero resultante (con extensión ``.yml``) al repositorio ``git``. También deben añadir los ficheros VHDL desarrollados (el contador y su testbench, y el prbs y su testbench) al repositorio.


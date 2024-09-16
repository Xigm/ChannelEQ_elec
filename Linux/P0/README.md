# Ejemplos de VHDL y Makefiles

Se proporcionan aquí algunos ejemplos de circuitos que se pueden simular y
sintetizar.

Se proporcionan ficheros ``Makefile`` que automatizan los comandos necesarios
para realizar los distintos pasos de simulación, síntesis e implementación.

Se recomienda leer los ficheros Makefile, así como los códigos VHDL, e intentar
desarrollar códigos propios.

Es muy útil pasar la opción ``-n`` a ``make`` para saber qué comandos se
ejecutarán sin necesidad de ejecutarlos (y asi no veremos la salida de los
comandos en el log), por ejemplo:

        make -n
        make view -n
        make prog -n

**IMPORTANTE:** Estos ejemplos se proporcionan como material complementario que
se recomienda que el alumno trabaje ANTES de la práctica 1. No se dedicará
ninguna sesión presencial a revisar este código, pues corresponde a material de
nivel de grado. No obstante se atenderán dudas sobre el material en tutorías.

## Ejemplos

1. [Latch](latch)
   - Este código infiere un Latch, y si intentamos sintetizarlo obtendremos un
     error. ¿Podrías corregirlo?
2. [Leds](leds)
   - Este diseño simplemente mueve leds en la tarjeta en función de las
     pulsaciones de los botones
   - Lee el código y su testbench, y también el Makefile
3. Multiplexor 2 a 1
   - En [estas transparencias](https://heimdall.us.es/docs/docencia/vhdl/temas/VHDL2.pdf),
     entre las páginas 18 y 26, se pueedn ver varias implementaciones posibles
     de un multiplexor 2 a 1. Entre las 5 implementaciones se muestran todas
     las sentencias que permiten tomar decisiones en un diseño VHDL.
   - Se recomienda leer y entender los códigos.
4. [Contador](contador)
   - Un contador con su testbench.
     - Lee el código del contador y su testbench y asegúrate de entenderlos
     - ¿Puedes escribir el Makefile para poder simularlo? Puedes inspirarte en
       el Makefile de los leds. Para simulación no es necesario que generes los
       ficheros ``.json``, ``.asc``, ``.bin`` ni el target ``prog``, ya que
       esos son para la implementación en la FPGA.
5. [Driver VGA](vga)
   - El driver VGA es un circuito basado en dos contadores, uno cuenta píxeles
     y otro cuenta líneas. También genera las señales de sincronismo que
     necesita el protocolo VGA y genera algunos dibujos, seleccionables
     pulsando los botones de la tarjeta.
   - En el Makefile de este diseño puedes encontrar una explicación de las
     reglas genéricas de GNU Make. Asegúrate de que entiendes la regla para
     generar ficheros ``.o`` a partir de ficheros ``.vhd``.
     - ¿Cómo afecta esta regla a la extensión del Makefile, ahora que tenemos 6
       ficheros ``.vhd``?
     - ¿Puedes escribir una regla genérica para otra de las extensiones que
       genera el Makefile, o mejorar alguna de las reglas? Por ejemplo, la
       regla que genera ``top.json`` podría beneficiarse de utilizar ``$^``


## Ejercicios recomendados

Se recomienda realizar los siguientes ejercicios, simulándolos a cada paso:

1. Contador
   - Escribir desde cero un contador de 8 bits sencillo, con un proceso
     combinacional que únicamente incremente el próximo valor de la cuenta y un
     proceso síncrono que incluya un reset asíncrono.
   - Añadir entrada ``enable`` al contador
     - Si ``enable`` vale '0', no se modifica el valor de la cuenta. Si vale
       '1', se incrementa en '1'.
   - Añadir un generic, ``N``, para convertirlo en un contador genérico de N
     bits.
   - Añadir un puerto de entrada ``updown``
     - Mientras el contador esté habilitado, si ``updown`` vale '1', debe
       contar hacia arriba, mientras que si vale '0', debe contar hacia abajo.
     - Si el contador está deshabilitado, no se modifica el valor de la
       cuenta, independientemente del valor de ``updown``.
   - Añadir un generic, ``SAT_VALUE``, de tipo ``integer (range 0 to 2**N-1)``,
     y una nueva salida, ``sat``, de forma que cuando el valor de cuenta sea
     igual a ``SAT_VALUE`` y el contador esté habilitado:
     - La salida ``sat`` se active combinacionalmente
     - El próximo valor de la cuenta sea 0
     - Se deja al alumno las posibles consideraciones de cómo este nuevo
       comportamiento se vería afectado por la entrada ``updown``
2. Multiplexor 4 a 1
   - Describir un multiplexor 4 a 1 de las siguientes maneras:
     1. Usando, dentro de un process, una sentencia if...elsif..else
     2. Usando, dentro de un process, una sentencia case...when
     3. Usando, fuera de un process, una sentencia when...else
     4. Usando, fuera de un process, una sentencia with...select
     5. Instanciando 3 multiplexores 2 a 1
     6. Es posible implementar este multiplexor escribiendo una única sentencia
        concurrente bastante larga. Puedes darle una pensada, te hará ver por
        qué es interesante utilizar los constructos que nos ofrece el lenguaje
        VHDL.
3. Contador y leds
   - Reutilizar el contador genérico, instanciándolo con un número suficiente
     de bits como para poder contar hasta varios millones de ciclos (la
     frecuencia del reloj externo de la FPGA es de 12 MHz)
   - Desarrollar un circuito síncrono del tipo que prefieras (por ejemplo un
     contador o un registro de desplazamiento) que se habilite con los pulsos
     de ``sat`` del contador y que, a cada activación saque una salida
     diferente por los 5 leds de la tarjeta (en PMOD2)
   - Puede simularse con un valor pequeño de ``SAT_VALUE``
   - A la hora de probarlo en la tarjeta, no olvidar usar el valor correcto de
     ``SAT_VALUE``
4. Máquina de estados
   - Cambiar el circuito anterior para que sea una máquina de estados que en
     cada estado encienda una combinación de leds diferente. Cada vez que
     la señal ``sat`` valga '1', se pasará al siguiente estado.
5. Simón dice
   - ¿Puedes hacer el juego del Simón, con una secuencia fija, utilizando los 3
     botones y 3 leds de la tarjeta?
     - Para conseguirlo, puedes adaptar la máquina de estados desarrollada
       anteriormente
     - Necesitarás también guardar en un biestable un entero con la longitud de
       la secuencia que ha acertado el jugador
     - En la máquina de estados, a veces tendrás que avanzar en la secuencia y
       otras veces tendrás que volver al principio

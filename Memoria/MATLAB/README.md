---
author:
- |
  Miguel Nogales González-Regueral\
  \
  Escuela Técnica Superior de Ingeniería\
  **Universidad de Sevilla**\
  Sevilla, España
title: |
  ![image](Figures/Logo_US.png){width="6cm"}\
  **Proyecto estimador de canal OFDM en MATLAB**
---

::: preview
:::

::: preview
# Introducción

Esta memoria servirá para detallar la funcionalidad de los códigos
usados para la parte sobre programación en Matlab de la asignatura
\"Electrónica Digital para Comunicaciones\" de 1º de MUIT y será
presentada junto a otra memoria complementaria sobre códigos en VHDL y
verificación.

El proyecto de la asignatura trata de realizar un estimador de canal
enteramente en VHDL y opcionalmente complementarlo con la equalización,
además de realizar verificación del funcionamiento de los códigos
aportados. El código de Matlab servirá como base y guía y para este fin,
adicionalmente pudiendose usar para verificación.

Primero se comentarán temas generales y algunas de las gráficas
obtenidas, con algunos detalles. Posteriomente estarán los códigos y sus
comentarios.

# Estimador de canal

Este trabajo instanciará un sistema OFDM en transmisión y recepción
siguiendo el estándar de DVT además de añadir los efectos del canal.
Este sistema OFDM tiene ciertas características definidas como el ancho
de banda de portadoras, el número de estas o como se organizan los
pilotos para la estimación de canal.

Para este ejemplo se usará una 16-QAM, mostrandose las figuras más
importantes. La constelación transmitida se puede ver en la Figura
[\[fig1\]](#fig1){reference-type="ref" reference="fig1"}, apreciando
sobre todo como los símbolos están bastante cercanos entre ellos, lo
cual empeora la BER, aunque permite enviar mayor cantidad de
información.

::: center
![image](../../Matlab/Figures/constelacion.eps){width="1\\columnwidth"}
:::

[]{#fig1 label="fig1"}

Algunas características de la señal OFDM interesantes y a tener en
cuanta son sus características espectrales y temporales. En frecuencia
la señal tiene un ancho de banda determinado muy abrupto, útil por su
eficiencia espectral, mientras que en tiempo, a diferencia de otras
técnicas de modulación, no se puede diferenciar nada a simple vista
debido a la transformación por medio de la IFFT realizada en el
transmisor.

::: center
![image](../../Matlab/Figures/psd.eps){width="1\\columnwidth"}
:::

[]{#fig2 label="fig2"}

::: center
![image](../../Matlab/Figures/muestrasTiempo.eps){width="1\\columnwidth"}
:::

[]{#fig3 label="fig3"}

Esta señal se pasará por el canal y mediante los pilotos, los cuales se
introducen en el esquema elegido cada 12 muestras, se estimará el canal
despúes de deshacer el código con el bloque de PRBS definido en el
estándar. El canal propuesto para probar el sistema junto con su
estimación se muestra en la Figura
[\[fig4\]](#fig4){reference-type="ref" reference="fig4"}.

::: center
![image](../../Matlab/Figures/canalestimado.eps){width="1\\columnwidth"}
:::

[]{#fig4 label="fig4"}

Para concluir, la constelacion habiendo deshecho los efectos del canal
es la siguiente:

::: center
![image](../../Matlab/Figures/constRX.eps){width="1\\columnwidth"}
:::

[]{#fig5 label="fig5"}

BER = 0.041821
:::

::: preview
# Análisis de los códigos

## Channel

Este primer código es la función que se encarga de modelar el canal y de
convolucionarlo con la señal. Este canal se define en frecuencia
discreta y mediante una sentencia vectorial se prepara el canal para
cada uno de los *taps*, despúes se suman todos. Mediante la IFFT se pasa
a frencuencia y después se convoluciona.

## Noise

La función que define el ruido es muy sencilla, se le pasa de parámetros
la señal y la SNR y así se le suma el ruido con la potencia correcta
para cumplir la relación señal a ruido.
:::

::: preview
## OFDM TX DVT

El código del transmisor ya empieza a ser más complejo. Se definen unos
parámetros por defecto y la colocación de los pilotos (cada 12
muestras). Posteriormente se añade el bloque PRBS calculándose tantos
signos para los pilotos como sea necesario por la cantidad de símbolos.
Luego se define la constelación dentro de las tres posibles y se genera
una secuancia aleatoria de bits a transmitir.

El siguiente paso consta del cambio de bits a símbolos, primero
pasandolo a decimales mediante una transformación con una matriz de
potencias de dos y luego pasandoselo como índice a la matriz de la
constelación, definida de manera que use codificación de Gray.

Luego solo resta la conversión de serie a paralelo e IFFT. Habiendo
realizado estos pasos la señal de transmisión está creada.
:::

::: preview
## OFDM RX DVT

Por otro lado está el transmisor el cual realiza los procesos inversos
al transmisor, pasando de parelaleo a serie, quitando el prefijo
cíclico, haciendo la FFT y demás. En la línea 69 se realiza la
estimación del canal, calculando la H a partir de los piltoos, los
cuales ya se les ha quitado el código. Después se encuentra un bucle for
el cual itera sobre los varios símbolos OFDM recibidos, interpolando
mediante ciertas operaciones matriciales y diviendiendo los datos
recibidos entre ese canal estimado, realizando una equalización *zero
forcing*. Posteriormente se demodula la constelación equalizada usando
propiedades para no tener que calcular la distancia mínima a los puntos.
:::

::: preview
## Integración

Este código sirve a modo de *toplevel*, para unificar las funcione y
otorgar cierta parametrización al conjunto de manera que se puedan
simular muchas posibilidades.
:::

::: preview
# Octave It

Esta sección mostrará y comentará brevemente los códigos modificados más
importantes que se han usado para verificación con CoCoTb, siendo
llamados por la librería Oct2py.

## PRBS

Código del PRBS directamente extraído de los códigos de transmisor y
receptor, y encapsulado en una función.

## Golden Channel Estimator

De la misma manera que el código anterior, se encapsula gran parte del
sistema, pero sin llegar a demodular ya que no es necesario. Se
devuelven los valores de las muestras transmitidas, la h estimada, el
canal interpolado v, los pilotos y la señal ecualizada.
:::

::: preview
# Resumen hitos realizados

Recogiendo todo lo mencionado anteriormente, se han realizado las
siguientes tareas:

-   Realización de los códigos en Matlab para el estimador de canal,
    receptor y transmisor.

-   Optimización de estos minimizando los bucles mediante programación
    vectorial.

-   Modos 2k y 8k, gran parametrización del código.

-   Añadido de 16-QAM.

-   Programación en funciones para aumentar la interoperabilidad.

-   Preparación de códigos para ser movidos en Octave vía Oct2Py.
:::

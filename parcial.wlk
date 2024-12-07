
class Alma {

    var tiempoDeViajeAlReposo = 4

    method tiempoDeViajeAlReposo() = tiempoDeViajeAlReposo

    method restarTiempoDePaquete(paquete) {
    if(tiempoDeViajeAlReposo - paquete.aniosQueReduce(self) < 0)
    tiempoDeViajeAlReposo = 0
    else
    tiempoDeViajeAlReposo =- paquete.aniosQueReduce(self) 
    }
    
    var dinero 

    var accionesBuenas 

    method accionesBuenas() = accionesBuenas

    method capital() = dinero + accionesBuenas

    method tieneSuficienteCapital(cantidad) = self.capital() > cantidad    
}


class Paquete {

    var valorBasico

    method valorBasico() = valorBasico

    method aniosQueReduce(alma)

    method costo(alma) = 
    if(valorBasico*self.aniosQueReduce(alma) > 350)
    350 
    else
    valorBasico*self.aniosQueReduce(alma)
}

class PaqueteTren inherits Paquete{

    override method aniosQueReduce(alma) = 4
}

class PaqueteBote inherits Paquete {

    method superaLosDosAnios(alma) =
    (alma.cantidadDeAccionesBuenas() / 50) > 2
    
    override method aniosQueReduce(alma) = 
    if(self.superaLosDosAnios(alma).negate())
    alma.cantidadDeAccionesBuenas() / 50
    else 
    2
}

class PaquetePaloConBrujula inherits Paquete {

    override method aniosQueReduce(alma) = 0.05

    override method costo(alma) = valorBasico
}

class PaqueteCrucero inherits PaqueteBote {

    override method aniosQueReduce(alma) = super(alma) * 2
}

object departamentoDeLaMuerte {

    var agentes = []

    method agentes() = agentes

    method agregarAgente(agente) {
        agentes.add(agente)
    }

    var paquetesDisponibles = []

    method agregarPaquete(paquete) {
        paquetesDisponibles.add(paquete)
    }

    method paquetesDisponibles() = paquetesDisponibles

    method mejorAgente() =
    agentes.max {agente => agente.cantidadDePaquetesVendidos()}

    method reducirDeudaAlMejor() {
    const elMejor = self.mejorAgente()
    elMejor.reducirDeudaEn(50)
    }

    method chequeoDeDueudas() {
        agentes.removeAllSuchThat{ agente => agente.tieneDeudaEn0()}
    } 

    method aumentarDeuda() {
        agentes.forEach{ agente => agente.aumentarDeudaEn(100)}
    }
    
    method pasarDiaDeMuertos() {
        self.reducirDeudaAlMejor()
        self.chequeoDeDueudas()
        self.aumentarDeuda()
    }
}


class Agente {

    var deuda 

    var estrategia

    method deuda() = deuda 

    var paquetesVendidos = []

    method cantidadDePaquetesVendidos() = paquetesVendidos.size()

    method dineroGanado() = paquetesVendidos.sum {paquete => paquete.costo()}

    method reducirDeudaEn(cantidad) {
        if(deuda < cantidad )
        deuda = 0
        else
        deuda = deuda - cantidad  
    }

    method aumentarDeudaEn(cantidad) {
        deuda = deuda + cantidad
    }

    method tieneDeudaEn0() = deuda == 0

    method paquetesVendidos() = paquetesVendidos
    
    method puedeVenderElPaquete(alma,paquete) =
    alma.tieneSuficienteCapital(paquete.costo(alma))

    method cambiarEstrategia(nuevaEstrategia) {
    estrategia = nuevaEstrategia 
    }

    method venderPaqueteA(alma,paquete) {
    if(self.puedeVenderElPaquete(alma,paquete)) { 
    paquetesVendidos.add(paquete)
    alma.restarTiempoDePaquete(paquete)
    }
    else 
    self.error("No se le puede vender el paquete al alma")
    }

    method antenderAlma(alma) {
        const paquete = self.paqueteSegunEstrategia(alma)
        self.venderPaqueteA(alma, paquete)
    }

    method paqueteSegunEstrategia(alma) {
    return estrategia.criterio(alma)
    }

}

object clasico {

    method paquetesPagables(alma) {
     return departamentoDeLaMuerte.paquetesDisponibles().filter {paquete => alma.tieneSuficienteCapital(paquete.costo(alma)) }
    }
    
    method criterio(alma) {
    const paquetesPosibles = self.paquetesPagables(alma)
    return paquetesPosibles.max{ paquete => paquete.costo(alma)}
    }
}

object navegante {
    
    method condicion(alma) = alma.accionesBuenas() >= 50
    
    method criterio(alma) {
    if(self.condicion(alma)) 
    return new PaqueteCrucero(valorBasico = alma.accionesBuenas())
    else 
    return new PaqueteBote(valorBasico = alma.accionesBuenas())
    }
}

object indiferente{

    method criterio(alma) {
        return new PaquetePaloConBrujula(valorBasico = 1.randomUpTo(300))
    }
    
}
using Agents, Random
using StaticArrays: SVector

@agent struct Car(ContinuousAgent{2,Float64}) 
    accelerating::Bool = true   #propiedad de acelerar para saber si debe acelerar o frenar (Ahora cada Car que creemos tendrá un campo adicional llamado accelerating, que por defecto será true.)
end

#funciones de comportamiento
accelerate(agent) = agent.vel[1] + 0.05
decelerate(agent) = agent.vel[1] - 0.1 

#Qué hace:
#Define dos nuevas funciones de ayuda: accelerate y decelerate.
#Dentro de agent_step!, decide si acelerar o frenar basándose en el estado agent.accelerating.
#Controla que la velocidad no exceda los límites de 1.0 (máxima) y 0.0 (mínima).
#Cuando alcanza un límite, invierte su estado (si estaba acelerando, ahora empieza a frenar, y viceversa).
#Finalmente, actualiza la velocidad del agente y lo mueve. El 0.4 en move_agent! es un factor que modula la distancia que se mueve en cada paso, puedes experimentar con él.
function agent_step!(agent, model)
    # Decide si acelerar o frenar
    new_velocity = agent.accelerating ? accelerate(agent) : decelerate(agent)

    #lógica para cambiar de estado (frenar/acelerar)
    if new_velocity >= 1.0
        new_velocity = 1.0
        agent.accelerating = false
    elseif new_velocity <= 0.0
        new_velocity = 0.0
        agent.accelerating = true
    end
    
    #actualiza la velocidad del agente y muévelo
    agent.vel = (new_velocity, 0.0)
    move_agent!(agent, model, 0.4)
end

#Que hace:
#Coloca a cada auto en una "fila" o carril diferente incrementando la coordenada py.
#Al primer auto le asigna una velocidad máxima de 1.0.
#A los demás autos les asigna una velocidad aleatoria en un rango más moderado (0.2 a 0.7).
function initialize_model(extent = (25, 10)) 
    space2d = ContinuousSpace(extent; spacing = 0.5, periodic = true)
    rng = Random.MersenneTwister()

    model = StandardABM(Car, space2d; rng, agent_step!, scheduler = Schedulers.Randomly())

    first = true
    py = 1.0 #pos Y inicial para el primer carril
    for px in randperm(25)[1:5]
        if first
            # primer auto (azul) empieza con velocidad máxima
            add_agent!(SVector{2, Float64}(px, py), model; vel=SVector{2, Float64}(1.0, 0.0))
            first = false # Asegúrate de que solo el primero tenga esta condición (para que solo el primero sea diferente)
        else
            # Los otros autos (rojos) empiezan con velocidad aleatoria
            add_agent!(SVector{2, Float64}(px, py), model; vel=SVector{2, Float64}(rand(Uniform(0.2, 0.7)), 0.0))
        end
        py += 2.0 # Mueve el siguiente auto al carril de abajo
    end
    model
end

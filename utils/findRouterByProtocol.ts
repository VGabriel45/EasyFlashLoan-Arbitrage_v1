import { Routers } from "../constants"

export const findRouterByProtocol = (protocol: number) => {
    return Routers[Object.keys(Routers)[protocol]!];
}
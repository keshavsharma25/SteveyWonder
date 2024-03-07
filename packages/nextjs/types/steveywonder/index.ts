import { ContractName } from "~~/utils/scaffold-eth/contract";

export type Option = Exclude<ContractName, "Account" | "ERC6551Registry" | "SteveyWonder">;

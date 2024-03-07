import { useEffect, useState } from "react";
import { useScaffoldContractRead } from "../scaffold-eth";
import { Address } from "viem";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Option = {
  name: ContractName;
  address: Address;
};

export const useBalanceOfOwner = ({ name, address }: Option) => {
  const [balance, setBalance] = useState<bigint>(BigInt(0));

  const { data: addrBalance } = useScaffoldContractRead({
    contractName: name,
    functionName: "balanceOf",
    args: [address],
  });

  useEffect(() => {
    if (addrBalance) {
      setBalance(addrBalance);
    }
  }, [addrBalance]);

  return { balance };
};

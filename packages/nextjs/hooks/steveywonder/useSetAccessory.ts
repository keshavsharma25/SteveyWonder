import { useDeployedContractInfo, useScaffoldContractWrite } from "../scaffold-eth";
import { Option } from "~~/types/steveywonder";

type Options = {
  option: Option;
  tokenId: bigint | undefined;
  optionTokenId: bigint | undefined;
};

export const useSetAccessory = ({ option, tokenId, optionTokenId }: Options) => {
  const { data: optionInfo } = useDeployedContractInfo(option);

  const { writeAsync, status } = useScaffoldContractWrite({
    contractName: "SteveyWonder",
    functionName: "setActiveAccessories",
    args: [optionInfo?.address as string | undefined, tokenId, optionTokenId],
  });

  return { writeAsync, status };
};

import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Props = {
  name: string;
  contractName: Exclude<ContractName, "SteveyWonder" | "Account" | "ERC6551Registry">;
  tokenId: bigint;
};

export const MintAccs = ({ name, contractName, tokenId }: Props) => {
  // const { address } = useAccount();

  const { write } = useScaffoldContractWrite({
    contractName: contractName,
    functionName: "safeMint",
    args: [tokenId],
  });

  return (
    <button
      onClick={() => {
        write?.();
      }}
      className="bg-[#3C44FF] hover:bg-[#3036cc] text-white font-bold py-2 px-4 rounded"
    >
      {name}
    </button>
  );
};

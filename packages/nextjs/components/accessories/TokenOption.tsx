import { useAccount } from "wagmi";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

type TokenOptionProps = {
  index: bigint;
};

export const TokenOption = ({ index }: TokenOptionProps) => {
  const { address } = useAccount();

  const { data: tokenId } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "tokenOfOwnerByIndex",
    args: [address, index],
    watch: true,
  });

  if (!tokenId) {
    return null;
  }

  return <option value={Number(tokenId)}>{Number(tokenId)}</option>;
};

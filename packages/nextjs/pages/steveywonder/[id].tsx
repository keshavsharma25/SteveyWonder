import { GetServerSidePropsContext, InferGetServerSidePropsType } from "next";
import { ItemContainer } from "~~/components/steveywonder";
import { ShowSteveyWonder } from "~~/components/steveywonder/main/ShowSteveyWonder";
import { useRenderTokenSVGWithoutBg } from "~~/hooks/steveywonder/useRenderTokenSVGWithoutBg";

const SteveyWonderId = ({ id }: InferGetServerSidePropsType<typeof getServerSideProps>) => {
  const { base64Image } = useRenderTokenSVGWithoutBg(BigInt(id));

  return (
    <section className="flex flex-1 justify-center items-center gap-12">
      {id < 1 ? (
        <div className="flex justify-center items-center">
          <h1>Invalid Stevey Wonder</h1>
        </div>
      ) : (
        <div className="flex gap-12 h-[37.9375rem]">
          <ShowSteveyWonder data={base64Image} width={518} height={607} />
          <div className={"bg-[#161728] w-[50rem] p-10 rounded-2xl shadow-md"}>
            <ItemContainer tokenId={Number(id)} />
          </div>
        </div>
      )}
    </section>
  );
};

export const getServerSideProps = (context: GetServerSidePropsContext) => {
  const id = context.query.id;

  if (typeof id === "string") {
    return { props: { id: Number(id) } };
  }

  return { props: { id: -1 } };
};

export default SteveyWonderId;
